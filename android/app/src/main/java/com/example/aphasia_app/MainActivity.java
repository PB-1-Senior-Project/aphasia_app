package com.example.aphasia_app;

import android.annotation.SuppressLint;
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
import com.google.mlkit.vision.common.PointF3D;
import com.google.mlkit.vision.facemesh.FaceMesh;
import com.google.mlkit.vision.facemesh.FaceMeshDetection;
import com.google.mlkit.vision.facemesh.FaceMeshDetector;
import com.google.mlkit.vision.facemesh.FaceMeshDetectorOptions;
import com.google.mlkit.vision.facemesh.FaceMeshPoint;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String METHOD_CHANNEL = "aphasia_app/face_mesh_method";
    private boolean isInitialized = false;



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
                                            ProcessCameraProvider cameraProvider = cameraProviderFuture.get();

                                            FaceAnalyzer faceAnalyzer = new FaceAnalyzer();




                                            // Set up the capture use case to allow users to take photos
                                            imageAnalysis = new ImageAnalysis.Builder()
                                                    .setTargetResolution(
                                                            new Size(480, 360))
                                                    .setBackpressureStrategy(
                                                            ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                                                    .setImageQueueDepth(2)
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
                                    // Task completed successfully

                                    for (FaceMesh faceMesh : output) {
                                        Rect bounds = faceMesh.getBoundingBox();
                                        System.out.println("Face Mesh");
                                        System.out.println(bounds.left);

                                        // Gets all points
                                        List<FaceMeshPoint> faceMeshPoints = faceMesh.getAllPoints();

                                        List<PointF3D> points = new ArrayList<>();

                                        for (FaceMeshPoint faceMeshpoint : faceMeshPoints) {

                                            PointF3D position = faceMeshpoint.getPosition();
                                            points.add(position);


                                        }

                                        System.out.println(points);
//
//                                                    // Gets triangle info
//                                                    List<Triangle<FaceMeshPoint>> triangles = faceMesh.getAllTriangles();
//                                                    for (Triangle<FaceMeshPoint> triangle : triangles) {
//                                                        // 3 Points connecting to each other and representing a triangle area.
//                                                        List<FaceMeshPoint> connectedPoints = triangle.getAllPoints();
//                                                    }
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
    }

}
