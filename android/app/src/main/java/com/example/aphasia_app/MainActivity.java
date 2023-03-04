package com.example.aphasia_app;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Rect;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.media.Image;
import android.os.Build;
import android.os.Handler;
import android.renderscript.ScriptGroup;
import android.util.SparseIntArray;
import android.view.Surface;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.google.android.gms.common.util.ArrayUtils;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.common.util.concurrent.ListenableFuture;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.common.PointF3D;
import com.google.mlkit.vision.common.Triangle;
import com.google.mlkit.vision.facemesh.FaceMesh;
import com.google.mlkit.vision.facemesh.FaceMeshDetection;
import com.google.mlkit.vision.facemesh.FaceMeshDetector;
import com.google.mlkit.vision.facemesh.FaceMeshDetectorOptions;
import com.google.mlkit.vision.facemesh.FaceMeshPoint;
//import com.google.mlkit.vision.demo.CameraSource;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.EventChannel;

import androidx.annotation.RequiresApi;
import androidx.camera.core.Camera;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageCapture;
import androidx.camera.core.ImageCaptureException;
import androidx.camera.core.ImageProxy;
import androidx.camera.core.Preview;
import androidx.camera.core.impl.CameraCaptureResult;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.camera.view.CameraController;
import androidx.camera.core.CameraControl;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.LifecycleOwner;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;
//import androidx.camera.lifecycle.ProcessCameraProvider;
import java.util.logging.StreamHandler;

public class MainActivity extends FlutterActivity {
    private static final String METHOD_CHANNEL = "aphasia_app/face_mesh_method";
    private InputImage currentImage;
    FaceMeshDetector faceMeshDetector = FaceMeshDetection.getClient(
            new FaceMeshDetectorOptions.Builder().setUseCase(1).build()
    );
    //private static final String EVENT_CHANNEL = "aphasia_app/face_mesh_channel";
    //private ImageData imageData = new ImageData();

    //private Executor executor = Executors.newSingleThreadExecutor();
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine){
        super.configureFlutterEngine(flutterEngine);
        //new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), EVENT_CHANNEL).setStreamHandler();

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), METHOD_CHANNEL)
                .setMethodCallHandler(
                (call, result) -> { 
            // This method is invoked on the main thread
                    if(call.method.equals("startFaceDetection")){
                        startFaceDetection(call.arguments());

                        System.out.println("working");

                        Task<List<FaceMesh>> meshOutput = faceMeshDetector.process(currentImage)
                                .addOnSuccessListener(
                                        output -> {
                                            // Task completed successfully
                                            for (FaceMesh faceMesh : output) {
                                                Rect bounds = faceMesh.getBoundingBox();
                                                System.out.println("Face Mesh");
                                                System.out.println(bounds.left);
                                                // Gets all points
//                                                    List<FaceMeshPoint> faceMeshPoints = faceMesh.getAllPoints();
//                                                    for (FaceMeshPoint faceMeshpoint : faceMeshPoints) {
//                                                        int index = faceMeshPoints.getIndex();
//                                                        PointF3D position = faceMeshpoint.getPosition();
//                                                    }
//
//                                                    // Gets triangle info
//                                                    List<Triangle<FaceMeshPoint>> triangles = faceMesh.getAllTriangles();
//                                                    for (Triangle<FaceMeshPoint> triangle : triangles) {
//                                                        // 3 Points connecting to each other and representing a triangle area.
//                                                        List<FaceMeshPoint> connectedPoints = triangle.getAllPoints();
//                                                    }
                                            }

                                        })
                                .addOnFailureListener(
                                        new OnFailureListener() {
                                            @Override
                                            public void onFailure(Exception e) {
                                                // Task failed with an exception
                                                // …
                                            }
                                        });

                        //Image data = call.argument("image");
                       //Image image = Image
                        //System.out.println(image.getFormat());
                        //int testMessage = startFaceDetection(image);
                        //System.out.println(currentImage.getFormat());
                        //result.success();
//                        if(image.isEmpty()){
//                            result.error("UNAVAILABLE", "String not available", null);
//                        }
//                        else{
//                            result.success(testMessage);
//                        }

                    }
        });

       
    }
    private void startFaceDetection(Map x){
        //Map<String, String> key = x;
//        System.out.println("made sdffdssfdfdsfds it");
//        ArrayList test = (ArrayList) x.get("byteList");
//        System.out.println(test.get(0).getClass().getSimpleName());
        ArrayList bytesList = (ArrayList) x.get("byteList");
//        byte [] test = (byte[]) bytesList.get(0);
//        System.out.println("beef");
//        System.out.println(bytesList);
        byte[] byteArray = new byte[bytesList.size()];
        for (int i = 0; i < bytesList.size(); i++) {
            byteArray = ArrayUtils.concatByteArrays(byteArray, (byte[]) bytesList.get(i));
        }

        //System.out.println(byteArray);
        int [] strides = (int[]) x.get("strides");
        int width = (int) x.get("width");
        int height = (int) x.get("height");
        //int rotation = getRotationCompensation();
        //InputImage.fromByteArray()
        InputImage image = InputImage.fromByteArray(byteArray, width, height, 90, InputImage.IMAGE_FORMAT_NV21);
        currentImage = image;
//        Bitmap bmp = BitmapFactory.decodeByteArray(byteArray, 0, byteArray.length);
//        bmp.compress(Bitmap);
        return;
    }


//    private static final SparseIntArray ORIENTATIONS = new SparseIntArray();
//    static {
//        ORIENTATIONS.append(Surface.ROTATION_0, 0);
//        ORIENTATIONS.append(Surface.ROTATION_90, 90);
//        ORIENTATIONS.append(Surface.ROTATION_180, 180);
//        ORIENTATIONS.append(Surface.ROTATION_270, 270);
//    }
//
//    /**
//     * Get the angle by which an image must be rotated given the device's current
//     * orientation.
//     */
//    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
//    private int getRotationCompensation(String cameraId, Activity activity, boolean isFrontFacing)
//            throws CameraAccessException {
//        // Get the device's current rotation relative to its "native" orientation.
//        // Then, from the ORIENTATIONS table, look up the angle the image must be
//        // rotated to compensate for the device's rotation.
//        int deviceRotation = activity.getWindowManager().getDefaultDisplay().getRotation();
//        int rotationCompensation = ORIENTATIONS.get(deviceRotation);
//
//        // Get the device's sensor orientation.
//        CameraManager cameraManager = (CameraManager) activity.getSystemService(CAMERA_SERVICE);
//        int sensorOrientation = cameraManager
//                .getCameraCharacteristics(cameraId)
//                .get(CameraCharacteristics.SENSOR_ORIENTATION);
//
//        if (isFrontFacing) {
//            rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
//        } else { // back-facing
//            rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
//        }
//        return rotationCompensation;
//    }
}
//    class FaceAnalyzer implements ImageAnalysis.Analyzer{
//        FaceMeshDetector detector = FaceMeshDetection.getClient(
//                new FaceMeshDetectorOptions.Builder().setUseCase(1).build()
//        );










//    @Override
//        public void analyze(@NonNull ImageProxy imageProxy) {
//            @SuppressLint("UnsafeOptInUsageError") Image mediaImage = imageProxy.getImage();
//            if(mediaImage != null){
//                InputImage image = InputImage.fromMediaImage(mediaImage, imageProxy.getImageInfo().getRotationDegrees());
//                Task<List<FaceMesh>> task = detector.process(image);
//                //task.addOnSuccessListener().addOnFailureListener();
//            }        }
  //  }

// IHJDSFOIHDSAFHDSAOIUHFFSDIUOHFDSIUHFDSIUH

