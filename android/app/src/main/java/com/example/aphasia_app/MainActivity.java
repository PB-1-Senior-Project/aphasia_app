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
import androidx.camera.view.CameraController;
import androidx.camera.view.LifecycleCameraController;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.LifecycleOwner;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.Task;
import com.google.common.util.concurrent.ListenableFuture;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.facemesh.FaceMesh;
import com.google.mlkit.vision.facemesh.FaceMeshDetection;
import com.google.mlkit.vision.facemesh.FaceMeshDetector;
import com.google.mlkit.vision.facemesh.FaceMeshDetectorOptions;

import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String METHOD_CHANNEL = "aphasia_app/face_mesh_method";
    private boolean isInitialized = false;

    private ExecutorService cameraExecutor;

    private ImageAnalysis imageAnalysis;

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
                        cameraExecutor = Executors.newSingleThreadExecutor();
                        //Executors executor = Executors.newSingleThreadExecutor();
                        if(isInitialized == false){
                            ListenableFuture<ProcessCameraProvider> cameraProviderFuture = ProcessCameraProvider.getInstance(this);

                            cameraProviderFuture.addListener(() -> {
                                try {
                                    // Camera provider is now guaranteed to be available
                                    ProcessCameraProvider cameraProvider = cameraProviderFuture.get();

                                    FaceAnalyzer faceAnalyzer = new FaceAnalyzer();

                                    // Set up the view finder use case to display camera preview
                                    //Preview preview = new Preview.Builder().build();

                                    // Set up the capture use case to allow users to take photos
                                    imageAnalysis = new ImageAnalysis.Builder()
                                            .setTargetResolution(
                                                    new Size(480, 360))
                                            .setBackpressureStrategy(
                                                    ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                                            .build();
                                    imageAnalysis.setAnalyzer(getMainExecutor(), faceAnalyzer);

                                    // Choose the camera by requiring a lens facing
                                    CameraSelector cameraSelector = new CameraSelector.Builder()
                                            .requireLensFacing(CameraSelector.LENS_FACING_FRONT)
                                            .build();

                                    CameraController controller = new LifecycleCameraController(getContext());
                                    //controller.setImageAnalysisAnalyzer(getMainExecutor(), new MlKitAnalyzer(List.of(faceMeshDetector), COORDINATE_SYSTEM_VIEW_REFERENCED, get));
                                    // Attach use cases to the camera with the same lifecycle owner
                                    Camera camera = cameraProvider.bindToLifecycle(
                                            ((LifecycleOwner) this),
                                            cameraSelector,
                                            imageAnalysis);

                                    // Connect the preview use case to the previewView
                                    //preview.setSurfaceProvider(                                            previewView.getSurfaceProvider());
                                } catch (InterruptedException | ExecutionException e) {
                                    // Currently no exceptions thrown. cameraProviderFuture.get()
                                    // shouldn't block since the listener is being called, so no need to
                                    // handle InterruptedException.
                                }
                            }, ContextCompat.getMainExecutor(this));
                        }


//                        else{
//                            // Stop the camera
//                            cameraProvider
//                            isInitialized = false;
//
//                        }
                        else{

                            //PreviewView previewView = new PreviewView(getContext());
//                            ListenableFuture<ProcessCameraProvider> cameraProviderFuture = ProcessCameraProvider.getInstance(this);
//
//                            cameraProviderFuture.addListener(() -> {
//                                try {
//                                    // Camera provider is now guaranteed to be available
//                                    ProcessCameraProvider cameraProvider = cameraProviderFuture.get();
//
//                                    FaceAnalyzer faceAnalyzer = new FaceAnalyzer();
//
//                                    // Set up the view finder use case to display camera preview
//                                    //Preview preview = new Preview.Builder().build();
//
//                                    // Set up the capture use case to allow users to take photos
//                                    imageAnalysis = new ImageAnalysis.Builder()
//                                            .setTargetResolution(
//                                                    new Size(480, 360))
//                                            .setBackpressureStrategy(
//                                                    ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
//                                            .build();
//                                    imageAnalysis.setAnalyzer(getMainExecutor(), faceAnalyzer);
//
//                                    // Choose the camera by requiring a lens facing
//                                    CameraSelector cameraSelector = new CameraSelector.Builder()
//                                            .requireLensFacing(CameraSelector.LENS_FACING_FRONT)
//                                            .build();
//
//                                    CameraController controller = new LifecycleCameraController(getContext());
//                                    //controller.setImageAnalysisAnalyzer(getMainExecutor(), new MlKitAnalyzer(List.of(faceMeshDetector), COORDINATE_SYSTEM_VIEW_REFERENCED, get));
//                                    // Attach use cases to the camera with the same lifecycle owner
//                                    Camera camera = cameraProvider.bindToLifecycle(
//                                            ((LifecycleOwner) this),
//                                            cameraSelector,
//                                            imageAnalysis);
//
//                                    // Connect the preview use case to the previewView
//                                    //preview.setSurfaceProvider(                                            previewView.getSurfaceProvider());
//                                } catch (InterruptedException | ExecutionException e) {
//                                    // Currently no exceptions thrown. cameraProviderFuture.get()
//                                    // shouldn't block since the listener is being called, so no need to
//                                    // handle InterruptedException.
//                                }
//                            }, ContextCompat.getMainExecutor(this));









//                            cameraProviderFuture.addListener(() -> {
//
//                                    FaceAnalyzer faceAnalyzer = new FaceAnalyzer();
//                                ProcessCameraProvider cameraProvider = null;
//                                try {
//                                    cameraProvider = cameraProviderFuture.get();
//                                } catch (ExecutionException e) {
//
//                                    //Throwable.getClause();
//                                    throw new RuntimeException(e);
//                                } catch (InterruptedException e) {
//                                    throw new RuntimeException(e);
//                                }
//
//                                Preview preview = new Preview.Builder().build();
//
//                                    imageAnalysis = new ImageAnalysis.Builder()
//                                            .setTargetResolution(
//                                                    new Size(480, 360))
//                                            .setBackpressureStrategy(
//                                                    ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
//                                            .build();
//                                    imageAnalysis.setAnalyzer(getMainExecutor(), faceAnalyzer);
//
//                                    CameraSelector cameraSelector = new CameraSelector.Builder().requireLensFacing(CameraSelector.LENS_FACING_FRONT).build();
//
//                                    Camera camera = cameraProvider.bindToLifecycle(
//                                            ((LifecycleOwner) this),
//                                            cameraSelector,
//                                            preview,
//                                            imageAnalysis);
//
//

//                                catch  (InterruptedException | ExecutionException e){
//                                    throw InterruptedException
//                                }


//                            CameraController controller = new LifecycleCameraController(getContext());
//                            controller.bindToLifeCycle(LifecycleOwner);
                            //startCamera();
                            //CameraController controller = new LifecycleCameraController(getContext());

                             // Maybe do something here?


                            //((LifecycleCameraController) controller).bindToLifecycle(new LifecycleOwner());




                            //FaceAnalyzer faceAnalyzer = new ImageAnalysis.Builder();


                            //ProcessCameraProvider cameraProvider = null;
                            //ProcessCameraProvider cameraProvider = new ProcessCameraProvider();
                            //ListenableFuture<ProcessCameraProvider> cameraProvider = ProcessCameraProvider.getInstance(this);
                            //cameraProvider.bindToLifecycle((LifecycleOwner) this, CameraSelector.DEFAULT_FRONT_CAMERA);
                            //controller.setImageAnalysisAnalyzer(getMainExecutor(), faceAnalyzer);
                            //controller.setImageAnalysisAnalyzer(getMainExecutor() ,new MlKitAnalyzer(List.of(faceMeshDetector), COORDINATE_SYSTEM_VIEW_REFERENCED, get));
                            isInitialized = true;
                        }
                        startFaceDetection();

                        System.out.println("working");




                    }
        });

       
    }

    private void startCamera(){

//        CameraController cameraController = new LifecycleCameraController(getBaseContext()); // Maybe change to getContext()
//        FaceAnalyzer faceAnalyzer = new FaceAnalyzer();
//        faceAnalyzer.
//        //PreviewView previewView = new PreviewView(SimpleAdapter.ViewBinder);
//        cameraController.setImageAnalysisAnalyzer(getMainExecutor(), ;

//        ListenableFuture<ProcessCameraProvider> cameraProviderFuture = ProcessCameraProvider.getInstance(this);
//        cameraProviderFuture.addListener(Runnable {});
//        Preview preview = new Preview.Builder().build();
//        CameraSelector cameraSelector = CameraSelector.DEFAULT_FRONT_CAMERA;

//        try{
//            cameraProvider,un
//        }
    }


    private void startFaceDetection(){

        return;
    }


    private class FaceAnalyzer implements ImageAnalysis.Analyzer{
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
            if(mediaImage != null) {
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
                                imageProxy.close();
                                })
                        .addOnFailureListener(
                                new OnFailureListener() {
                                    @Override
                                    public void onFailure(Exception e) {
                                        imageProxy.close();
                                        // Task failed with an exception
                                        // …
                                    }
                                });
            }
        }
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

