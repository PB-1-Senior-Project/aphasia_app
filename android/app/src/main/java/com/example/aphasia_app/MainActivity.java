package com.example.aphasia_app;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.ContextWrapper;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.graphics.Rect;
import android.media.Image;
import android.util.Size;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.core.Camera;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageProxy;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.LifecycleOwner;

import com.google.android.gms.tasks.Task;
import com.google.common.util.concurrent.ListenableFuture;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.facemesh.FaceMesh;
import com.google.mlkit.vision.facemesh.FaceMeshDetection;
import com.google.mlkit.vision.facemesh.FaceMeshDetector;
import com.google.mlkit.vision.facemesh.FaceMeshDetectorOptions;
import com.google.mlkit.vision.facemesh.FaceMeshPoint;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;
import java.util.concurrent.ExecutionException;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String METHOD_CHANNEL = "aphasia_app/face_mesh_method";
    private boolean isInitialized = false;

    private ProcessCameraProvider cameraProvider;

    private ImageAnalysis imageAnalysis;

    FaceMeshDetector faceMeshDetector = FaceMeshDetection.getClient(
            new FaceMeshDetectorOptions.Builder().setUseCase(1).build()
    );



    @SuppressLint("UnsafeOptInUsageError")
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);


        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), METHOD_CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            // This method is invoked on the main thread
                            if (call.method.equals("startFaceDetection")) {

                                if (!isInitialized) {
                                    ListenableFuture<ProcessCameraProvider> cameraProviderFuture = ProcessCameraProvider.getInstance(this);

                                    cameraProviderFuture.addListener(() -> {
                                        try {


//                                            ImageAnalysis.Builder builder = new ImageAnalysis.Builder();
//                                            @SuppressLint("UnsafeOptInUsageError") Camera2Interop.Extender ext = new Camera2Interop.Extender<>(builder);
//                                            ext.setCaptureRequestOption(CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE, new Range<Integer>(1, 1));
//
//                                            ImageAnalysis imageAnalysis = builder.build();

                                            // Camera provider is now guaranteed to be available
                                            cameraProvider = cameraProviderFuture.get();

                                            FaceAnalyzer faceAnalyzer = new FaceAnalyzer();




                                            // Set up the capture use case to allow users to take photos
                                            imageAnalysis = new ImageAnalysis.Builder()
                                                    
                                                    .setBackpressureStrategy(
                                                            ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                                                    .setImageQueueDepth(1)
                                                    .build();
                                            imageAnalysis.setAnalyzer(getMainExecutor(), faceAnalyzer);

                                            // Choose the camera by requiring a lens facing
                                            CameraSelector cameraSelector = new CameraSelector.Builder()
                                                    .requireLensFacing(CameraSelector.LENS_FACING_FRONT)
                                                    .build();

                                            //CameraController controller = new LifecycleCameraController(getContext());

                                            // Attach use cases to the camera with the same lifecycle owner
                                            Camera camera = cameraProvider.bindToLifecycle(
                                                    ((LifecycleOwner) this),
                                                    cameraSelector,
                                                    imageAnalysis);

                                            // Connect the preview use case to the previewView

                                        } catch (InterruptedException | ExecutionException e) {
                                            // Currently no exceptions thrown. cameraProviderFuture.get()
                                            // shouldn't block since the listener is being called, so no need to
                                            // handle InterruptedException.
                                        }
                                    }, ContextCompat.getMainExecutor(this));
                                    isInitialized = true;
                                }


                                else {
                                    cameraProvider.unbindAll();
                                    imageAnalysis.clearAnalyzer();
                                    // Stop the Camera here
                                    isInitialized = false;
                                }

                            }
                        });


    }



    private class FaceAnalyzer implements ImageAnalysis.Analyzer {
        @Nullable
        @Override
        public Size getDefaultTargetResolution() {
            return ImageAnalysis.Analyzer.super.getDefaultTargetResolution();
        }

        @Override
        public int getTargetCoordinateSystem() {
            return ImageAnalysis.Analyzer.super.getTargetCoordinateSystem();
        }

        @Override
        public void updateTransform(@Nullable Matrix matrix) {
            ImageAnalysis.Analyzer.super.updateTransform(matrix);
        }

        @Override
        public void analyze(@NonNull ImageProxy imageProxy) {
            @SuppressLint("UnsafeOptInUsageError") Image mediaImage = imageProxy.getImage();



            if (mediaImage != null) {
                InputImage currentImage = InputImage.fromMediaImage(mediaImage, imageProxy.getImageInfo().getRotationDegrees());


                Task<List<FaceMesh>> meshOutput = faceMeshDetector.process(currentImage)
                        .addOnSuccessListener(

                                output -> {
                                    System.out.println("Running");
                                    if(!output.isEmpty()){
                                        System.out.println("Detected Face");
                                        FaceMesh faceMesh = output.get(0);
                                        List<FaceMeshPoint> faceMeshPoints = faceMesh.getAllPoints();

                                        Rect faceBox = faceMesh.getBoundingBox();
                                        int faceHeight = faceBox.height();
                                        int faceWidth = faceBox.width();
                                        int faceArea = faceHeight * faceWidth;

                                        @SuppressLint("UnsafeOptInUsageError") Bitmap bitmapImage = BitmapUtils.getBitmap(imageProxy);

                                        int bitmapWidth = bitmapImage.getWidth();
                                        int bitmapHeight = bitmapImage.getHeight();

//
                                        int rightEyeTopLeft = 70; // 68
                                        int rightEyeBottomRight = 236;
                                        int leftEyeTopRight = 300; // 298
                                        int leftEyeBottomLeft = 456;

                                        float rightEyeTopLeftX = faceMeshPoints.get(rightEyeTopLeft).getPosition().getX();
                                        float rightEyeTopLeftY = faceMeshPoints.get(rightEyeTopLeft).getPosition().getY();
                                        float rightEyeBottomRightX = faceMeshPoints.get(rightEyeBottomRight).getPosition().getX();
                                        float rightEyeBottomRightY = faceMeshPoints.get(rightEyeBottomRight).getPosition().getY();

                                        int rightEyeHeight = (int) Math.abs(rightEyeTopLeftY - rightEyeBottomRightY);
                                        int rightEyeWidth = (int) Math.abs(rightEyeTopLeftX - rightEyeBottomRightX);

                                        float leftEyeTopRightX = faceMeshPoints.get(leftEyeTopRight).getPosition().getX();
                                        float leftEyeTopRightY = faceMeshPoints.get(leftEyeTopRight).getPosition().getY();
                                        float leftEyeBottomLeftX = faceMeshPoints.get(leftEyeBottomLeft).getPosition().getX();
                                        float leftEyeBottomLeftY = faceMeshPoints.get(leftEyeBottomLeft).getPosition().getY();

                                        int leftEyeHeight = (int) Math.abs(leftEyeTopRightY - leftEyeBottomLeftY);
                                        int leftEyeWidth = (int) Math.abs(leftEyeTopRightX - leftEyeBottomLeftX);

                                        int eyeWidth = Math.max(rightEyeWidth, leftEyeWidth);
                                        int eyeHeight = Math.max(rightEyeHeight, leftEyeHeight);

                                        int newX = (int) Math.abs(bitmapImage.getWidth() - leftEyeTopRightX - 1);


                                        float rightCrashSize1X = rightEyeTopLeftX + eyeWidth;
                                        float rightCrashSize1Y = rightEyeTopLeftY + eyeHeight;


                                        int leftCrashSize2X = newX + eyeWidth;
                                        int leftCrashSize2Y = (int) (leftEyeTopRightY + eyeHeight);


                                        if(rightCrashSize1X >= bitmapWidth ||
                                                leftCrashSize2X >= bitmapWidth ||
                                                rightCrashSize1Y >= bitmapHeight ||
                                                leftCrashSize2Y >= bitmapHeight ||
                                                Math.min(Math.min(rightEyeTopLeftX, rightEyeTopLeftY), Math.min(newX, leftEyeTopRightY)) < 0){
                                            imageProxy.close();
                                            return;
                                        }


                                        Bitmap rightEye = Bitmap.createBitmap(bitmapImage, (int) rightEyeTopLeftX, (int) rightEyeTopLeftY, eyeWidth, eyeHeight);
                                        Bitmap upscaledRightEye = Bitmap.createScaledBitmap(rightEye, 128, 128, false);


                                        Matrix matrix = new Matrix();
                                        matrix.postScale(-1, 1, bitmapImage.getWidth() / 2f, bitmapImage.getHeight() / 2f);


                                        Bitmap rotated = Bitmap.createBitmap(bitmapImage, 0, 0, bitmapImage.getWidth(), bitmapImage.getHeight(), matrix, true);

                                        Bitmap leftEye = Bitmap.createBitmap(rotated, newX, (int) leftEyeTopRightY, eyeWidth, eyeHeight);
                                        Bitmap upscaledLeftEye = Bitmap.createScaledBitmap(leftEye, 128, 128, false);


                                        saveToInternalStorage(bitmapImage, "Face.jpg");
                                        saveToInternalStorage(upscaledLeftEye, "LeftEye.jpg");
                                        saveToInternalStorage(upscaledRightEye, "RightEye.jpg");


                                    }

                                    imageProxy.close();
                                })
                        .addOnFailureListener(
                                e -> {
                                    imageProxy.close();
                                    // Task failed with an exception
                                    // …
                                });
            }
        }

    private void saveToInternalStorage(Bitmap bitmapImage, String name){
        ContextWrapper cw = new ContextWrapper(getApplicationContext());
        // path to /data/data/yourapp/app_data/imageDir
        File directory = cw.getDir("imageDir", Context.MODE_PRIVATE);
        // Create imageDir
        File mypath=new File(directory, name);

        FileOutputStream fos = null;
        try {
            fos = new FileOutputStream(mypath);
            // Use the compress method on the BitMap object to write image to the OutputStream
            bitmapImage.compress(Bitmap.CompressFormat.JPEG, 100, fos);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                fos.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }


    }

}
