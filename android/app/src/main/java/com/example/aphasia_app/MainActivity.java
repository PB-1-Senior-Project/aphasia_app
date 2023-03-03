package com.example.aphasia_app;

import android.annotation.SuppressLint;
import android.media.Image;
import android.os.Handler;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.Task;
import com.google.common.util.concurrent.ListenableFuture;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.facemesh.FaceMesh;
import com.google.mlkit.vision.facemesh.FaceMeshDetection;
import com.google.mlkit.vision.facemesh.FaceMeshDetector;
import com.google.mlkit.vision.facemesh.FaceMeshDetectorOptions;
//import com.google.mlkit.vision.demo.CameraSource;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.EventChannel;

import androidx.camera.core.Camera;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageCapture;
import androidx.camera.core.ImageCaptureException;
import androidx.camera.core.ImageProxy;
import androidx.camera.core.Preview;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.camera.view.CameraController;
import androidx.camera.core.CameraControl;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.LifecycleOwner;

import java.io.File;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;
//import androidx.camera.lifecycle.ProcessCameraProvider;
import java.util.logging.StreamHandler;

public class MainActivity extends FlutterActivity {
    private static final String METHOD_CHANNEL = "aphasia_app/face_mesh_method";
    private static final String EVENT_CHANNEL = "aphasia_app/face_mesh_channel";

    //private Executor executor = Executors.newSingleThreadExecutor();
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine){
        super.configureFlutterEngine(flutterEngine);
        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), EVENT_CHANNEL).setStreamHandler(StreamHandler(imageData));

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), METHOD_CHANNEL)
                .setMethodCallHandler(
                (call, result) -> { 
            // This method is invoked on the main thread
                    if(call.method.equals("startFaceDetection")){
                        String testMessage = "test"; //startFaceDetection();
                        if(testMessage.isEmpty()){
                            result.error("UNAVAILABLE", "String not available", null);
                        }
                        else{
                            result.success(testMessage);
                        }

                    }
        });

       
    }

//    private class FaceAnalyzer implements ImageAnalysis.Analyzer{
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
//    }

// IHJDSFOIHDSAFHDSAOIUHFFSDIUOHFDSIUHFDSIUH
    private String startFaceDetection(File file){
        return ("This worked!");
    }
}
