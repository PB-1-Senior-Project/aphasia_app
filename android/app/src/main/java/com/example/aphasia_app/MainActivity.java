package com.example.aphasia_app;

import android.content.Context;
import android.content.ContextWrapper;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.media.Image;
import android.os.Handler;

import androidx.annotation.NonNull;
import androidx.camera.core.Camera;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.ExperimentalGetImage;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageProxy;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.core.content.ContextCompat;

import com.example.aphasia_app.ml.Model;
import com.google.android.gms.tasks.Task;
import com.google.common.util.concurrent.ListenableFuture;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.common.PointF3D;
import com.google.mlkit.vision.facemesh.FaceMesh;
import com.google.mlkit.vision.facemesh.FaceMeshDetection;
import com.google.mlkit.vision.facemesh.FaceMeshDetector;
import com.google.mlkit.vision.facemesh.FaceMeshDetectorOptions;
import com.google.mlkit.vision.facemesh.FaceMeshPoint;

import org.tensorflow.lite.DataType;
import org.tensorflow.lite.support.image.TensorImage;
import org.tensorflow.lite.support.tensorbuffer.TensorBuffer;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;
import java.util.concurrent.ExecutionException;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    // Method channel 
    private static final String METHOD_CHANNEL = "aphasia_app/face_mesh_method";
    // Event channel
    public static final String EVENT_CHANNEL = "aphasia_app/eye_tracking_output";

    private Model eyeModel;

    // Boolean variable describing if the camera is initialized or not
    private boolean isInitialized = false;

    // Array for the CNN output
    public float[] predicted = new float[2];

    private ProcessCameraProvider cameraProvider;

    private ImageAnalysis imageAnalysis;

    FaceMeshDetector faceMeshDetector = FaceMeshDetection.getClient(
            new FaceMeshDetectorOptions.Builder().setUseCase(1).build()
    );


    private EventChannel.EventSink attachEvent;
    private Handler handler;

    private final Runnable runnable = new Runnable() {
        @Override
        public void run() {
            if(attachEvent == null){
                System.out.println("oops");
                return;
            }
            attachEvent.success(predicted);
            handler.postDelayed(this, 200);
        }
    };


    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), EVENT_CHANNEL).setStreamHandler(
                new EventChannel.StreamHandler() {

                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {

                        attachEvent = events;
                        handler = new Handler();
                        runnable.run();


                    }

                    @Override
                    public void onCancel(Object arguments) {

                        handler.removeCallbacks(runnable);
                        handler = null;
                        attachEvent = null;
                        System.out.println("Stream Canceled");
                    }


                }
        );


        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), METHOD_CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            // This method is invoked on the main thread
                            if (call.method.equals("startFaceDetection")) {

                                if (!isInitialized) { // If the camera isn't initialized, then start the camera
                                    ListenableFuture<ProcessCameraProvider> cameraProviderFuture = ProcessCameraProvider.getInstance(this);
                                    cameraProviderFuture.addListener(() -> {
                                        try {

                                            // Get the camera provider
                                            cameraProvider = cameraProviderFuture.get();

                                            // Create analyzer class for image processing
                                            FaceAnalyzer faceAnalyzer = new FaceAnalyzer();

                                            // Set up the image analysis use case and pass the face analyzer above as the analyzer
                                            imageAnalysis = new ImageAnalysis.Builder()
                                                    .setBackpressureStrategy(
                                                            ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                                                    .setImageQueueDepth(1)
                                                    .build();
                                            imageAnalysis.setAnalyzer(getMainExecutor(), faceAnalyzer);

                                            // Selects the front camera
                                            CameraSelector cameraSelector = new CameraSelector.Builder()
                                                    .requireLensFacing(CameraSelector.LENS_FACING_FRONT)
                                                    .build();

                                            // Attach use cases to the camera and bind to a lifecycle
                                            Camera camera = cameraProvider.bindToLifecycle(
                                                    (this),
                                                    cameraSelector,
                                                    imageAnalysis);

                                            try {
                                                eyeModel = Model.newInstance(getApplicationContext());


                                            } catch (IOException e) {
                                                // TODO Handle the exception
                                            }

                                        } catch (InterruptedException | ExecutionException e) {

                                        }
                                    }, ContextCompat.getMainExecutor(this));
                                    // Set variable to true so you can track if the camera is recording or not
                                    isInitialized = true;
                                }

                                else { // Stops the camera if it is already initialized
                                    cameraProvider.unbindAll();
                                    imageAnalysis.clearAnalyzer();
                                    isInitialized = false;
                                }

                            }
                        });

    }

// Custom Analyzer class that handles creating the face mesh and manipulating the face mesh to get the inputs needed for the CNN
    private class FaceAnalyzer implements ImageAnalysis.Analyzer {

        // Called for each frame that the camera records
        @ExperimentalGetImage
        @Override
        public void analyze(@NonNull ImageProxy imageProxy) {

            // Gets the current frame
            Image mediaImage = imageProxy.getImage();

            if (mediaImage != null) { // Called if the image from the proxy is not null

                // Creates an InputImage from the camera frame so the face mesh detector can process it
                InputImage currentImage = InputImage.fromMediaImage(mediaImage, imageProxy.getImageInfo().getRotationDegrees());

                // Process the image for faces
                Task<List<FaceMesh>> meshOutput = faceMeshDetector.process(currentImage)
                        .addOnSuccessListener(

                                output -> { // Runs for each frame recorded

                                    if(!output.isEmpty()){ // Runs if the face mesh detector detects a face in the field of view of the camera

                                        // Get the face mesh for the first face detected (I'm having the code only use one face that is detected to prevent the feature from breaking if multiple people are in view)
                                        FaceMesh faceMesh = output.get(0);

                                        // Gets a list of all 468 points on the face mesh
                                        List<FaceMeshPoint> faceMeshPoints = faceMesh.getAllPoints();

                                        // Points on the face mesh used to calculate the yaw and pitch
                                        int yawPoint1 = 50;
                                        int yawPoint2 = 280;
                                        int pitchPoint1 = 10;
                                        int pitchPoint2 = 168;
                                        PointF3D yawPosition1 = faceMeshPoints.get(yawPoint1).getPosition();
                                        PointF3D yawPosition2 = faceMeshPoints.get(yawPoint2).getPosition();
                                        PointF3D pitchPosition1 = faceMeshPoints.get(pitchPoint1).getPosition();
                                        PointF3D pitchPosition2 = faceMeshPoints.get(pitchPoint2).getPosition();

                                        System.out.println("Face Detected");

                                        // Calculate the yaw and pitch
                                        double yaw = Math.atan((yawPosition1.getZ()-yawPosition2.getZ())/(yawPosition1.getX()-yawPosition2.getX()));
                                        double pitch = Math.atan((pitchPosition1.getZ()-pitchPosition2.getZ())/(pitchPosition1.getY()-pitchPosition2.getY()));
                                        pitch *= -1;
                                        yaw = yaw * 180/Math.PI;
                                        pitch = pitch * 180/Math.PI;

                                        System.out.println("Yaw: " + yaw);
                                        System.out.println("Pitch: " + pitch);

                                        // If the user isn't looking at the screen, skip the rest of the processing to save on resources
                                        if(yaw < -25 || yaw > 25 || pitch > 40 || pitch < -20){
                                            imageProxy.close();
                                            System.out.println("Skipped frame, User Not Looking at Screen");
                                            return;
                                        }

                                        // Turns the image proxy into a bitmap so it can be easily manipulated
                                        Bitmap bitmapImage = BitmapUtils.getBitmap(imageProxy);

                                        // Gets the height and width of the bitmap image for use later in processing
                                        assert bitmapImage != null;
                                        int bitmapWidth = bitmapImage.getWidth();
                                        int bitmapHeight = bitmapImage.getHeight();

                                        // indices for the points on the face mesh that correspond to the left and right eyes
                                        int rightEyeTopLeft = 70; // 68
                                        int rightEyeBottomRight = 236;
                                        int leftEyeTopRight = 300; // 298
                                        int leftEyeBottomLeft = 456;

                                        // X and Y coordinates for the right eye corners
                                        float rightEyeTopLeftX = faceMeshPoints.get(rightEyeTopLeft).getPosition().getX();
                                        float rightEyeTopLeftY = faceMeshPoints.get(rightEyeTopLeft).getPosition().getY();
                                        float rightEyeBottomRightX = faceMeshPoints.get(rightEyeBottomRight).getPosition().getX();
                                        float rightEyeBottomRightY = faceMeshPoints.get(rightEyeBottomRight).getPosition().getY();

                                        // Size of the right eye
                                        int rightEyeHeight = (int) Math.abs(rightEyeTopLeftY - rightEyeBottomRightY);
                                        int rightEyeWidth = (int) Math.abs(rightEyeTopLeftX - rightEyeBottomRightX);

                                        // X and Y coordinates for the left eye corners
                                        float leftEyeTopRightX = faceMeshPoints.get(leftEyeTopRight).getPosition().getX();
                                        float leftEyeTopRightY = faceMeshPoints.get(leftEyeTopRight).getPosition().getY();
                                        float leftEyeBottomLeftX = faceMeshPoints.get(leftEyeBottomLeft).getPosition().getX();
                                        float leftEyeBottomLeftY = faceMeshPoints.get(leftEyeBottomLeft).getPosition().getY();

                                        // Size of the left eye
                                        int leftEyeHeight = (int) Math.abs(leftEyeTopRightY - leftEyeBottomLeftY);
                                        int leftEyeWidth = (int) Math.abs(leftEyeTopRightX - leftEyeBottomLeftX);

                                        // Gets the size of the larger eye (used later to determine what height to crop the eye images to)
                                        int eyeWidth = Math.max(rightEyeWidth, leftEyeWidth);
                                        int eyeHeight = Math.max(rightEyeHeight, leftEyeHeight);

                                        // Create array to hold the normalized coordinates for the left and right eye corner landmarks
                                        float[] eyeCorners = {leftEyeTopRightX/bitmapWidth, leftEyeTopRightY/bitmapHeight,
                                                leftEyeBottomLeftX/bitmapWidth, leftEyeBottomLeftY/bitmapHeight,
                                                rightEyeTopLeftX/bitmapWidth, rightEyeTopLeftY/bitmapHeight,
                                                rightEyeBottomRightX/bitmapWidth, rightEyeBottomRightY/bitmapHeight};

                                        // Coordinate for the corner of the left eye that will result after flipping the image horizontally
                                        int newX = (int) Math.abs(bitmapImage.getWidth() - leftEyeTopRightX - 1);

                                        // Numbers describing what size image will crash the program if it were to try and crop the eyes out of the main image
                                        // (This is needed to prevent the program from crashing if the detected face is near the edges of the camera view)
                                        int rightCrashSize1X = (int) (rightEyeTopLeftX + eyeWidth);
                                        int rightCrashSize1Y = (int) (rightEyeTopLeftY + eyeHeight);
                                        int leftCrashSize2X = newX + eyeWidth;
                                        int leftCrashSize2Y = (int) (leftEyeTopRightY + eyeHeight);

                                        // If cropping the image would crash the program, skip the frame
                                        if(rightCrashSize1X >= bitmapWidth ||
                                                leftCrashSize2X >= bitmapWidth ||
                                                rightCrashSize1Y >= bitmapHeight ||
                                                leftCrashSize2Y >= bitmapHeight ||
                                                Math.min(Math.min(rightEyeTopLeftX, rightEyeTopLeftY), Math.min(newX, leftEyeTopRightY)) < 0){
                                            imageProxy.close();
                                            return;
                                        }

                                        // Creates a bitmap image for the right eye
                                        Bitmap rightEye = Bitmap.createBitmap(bitmapImage, (int) rightEyeTopLeftX, (int) rightEyeTopLeftY, eyeWidth, eyeHeight);

                                        // Upscales the right eye bitmap to 128x128 pixels
                                        Bitmap upscaledRightEye = Bitmap.createScaledBitmap(rightEye, 128, 128, true);

                                        // Creates a matrix that will flip the left eye bitmap horizontally
                                        Matrix matrix = new Matrix();
                                        matrix.postScale(-1, 1, bitmapImage.getWidth() / 2f, bitmapImage.getHeight() / 2f);

                                        // Flips the original bitmap image horizontally
                                        Bitmap rotated = Bitmap.createBitmap(bitmapImage, 0, 0, bitmapImage.getWidth(), bitmapImage.getHeight(), matrix, true);

                                        // Creates a bitmap image for the left eye
                                        Bitmap leftEye = Bitmap.createBitmap(rotated, newX, (int) leftEyeTopRightY, eyeWidth, eyeHeight);

                                        // Upscales the left eye bitmap to 128x128 pixels
                                        Bitmap upscaledLeftEye = Bitmap.createScaledBitmap(leftEye, 128, 128, true);

                                        // Saves the images of the face, left eye, and right eye on the device
//                                        saveToInternalStorage(bitmapImage, "Face.jpg");
//                                        saveToInternalStorage(upscaledLeftEye, "LeftEye.jpg");
//                                        saveToInternalStorage(upscaledRightEye, "RightEye.jpg");

                                        // Creates the left eye input to the CNN
                                        TensorImage tempInput0 = new TensorImage(DataType.FLOAT32);
                                        tempInput0.load(upscaledLeftEye);
                                        TensorBuffer inputFeature0 = tempInput0.getTensorBuffer();

                                        // Creates the right eye input to the CNN
                                        TensorImage tempInput1 = new TensorImage(DataType.FLOAT32);
                                        tempInput1.load(upscaledRightEye);
                                        TensorBuffer inputFeature1 = tempInput1.getTensorBuffer();

                                        // Creates the eye corner input to the CNN
                                        TensorBuffer inputFeature2 = TensorBuffer.createFixedSize(new int[]{1, 8}, DataType.FLOAT32);
                                        inputFeature2.loadArray(eyeCorners);

                                        // Runs model inference and gets result.
                                        Model.Outputs modelOutput = eyeModel.process(inputFeature0, inputFeature1, inputFeature2);

                                        // Gets the output from the CNN and converts it into an array
                                        TensorBuffer outputFeature0 = modelOutput.getOutputFeature0AsTensorBuffer();
                                        float[] outputArray = outputFeature0.getFloatArray();

                                        // Just filler code until the CNN works correctly
                                        // float[] testArray = new float[2];
                                        // testArray[0] = (float) Math.random();
                                        // testArray[1] = (float) Math.random();
                                        // predicted = testArray;

                                        // Used in the actual code to help send the output back to Flutter
                                        // Commented out until the CNN works correctly
//                                        predicted = outputArray;

                                    }
                                    // Closes the image proxy and continues to the next frame
                                    imageProxy.close();
                                })
                        .addOnFailureListener( // Runs when an exception occurs
                                e -> {
                                    imageProxy.close();
                                    // Task failed with an exception
                                    // …
                                });
            }
        }

        // Saves the bitmap image on the device as a JPEG
    private void saveToInternalStorage(Bitmap bitmapImage, String name){

        ContextWrapper cw = new ContextWrapper(getApplicationContext());
        // Gets the path to /data/data/com.example.aphasia_app/app_imageDir
        File directory = cw.getDir("imageDir", Context.MODE_PRIVATE);
        // Creates a directory for the files to go into called imageDir
        File mypath=new File(directory, name);

        FileOutputStream fos = null;
        try {
            fos = new FileOutputStream(mypath);
            // Compresses the bitmap into a JPEG and writes it to the output stream
            bitmapImage.compress(Bitmap.CompressFormat.JPEG, 100, fos);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                assert fos != null;
                fos.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }


    }

}
