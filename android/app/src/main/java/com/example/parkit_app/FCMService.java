package com.justpark.it.app;
import android.app.ActivityManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import androidx.core.app.NotificationCompat;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.google.gson.Gson;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.FlutterMain;

import static android.app.Notification.DEFAULT_SOUND;
import static android.app.Notification.DEFAULT_VIBRATE;

public class FCMService extends FirebaseMessagingService  {
    private static final String TAG = "MyFirebaseMsgService";
    
    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        Gson gson = new Gson();
        String json = gson.toJson(remoteMessage.getData());
        Log.d(TAG, "Json string is " + json);
        SharedPreferences prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE);
        SharedPreferences.Editor editor=prefs.edit();
        editor.putString("flutter.userId",remoteMessage.getData().get("userId"));
        editor.putString("flutter.name",remoteMessage.getData().get("name"));
        editor.apply(); 
        Log.d("user id",remoteMessage.getData().get("userId"));
        Log.d("name",remoteMessage.getData().get("name"));
        Handler handler = new Handler(Looper.getMainLooper());

        handler.post(new Runnable() {
            @Override
            public void run() {
                Intent intent1 = new Intent(getBaseContext(), MainActivity.class);
                intent1.setAction(Intent.ACTION_VIEW);
                intent1.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                intent1.putExtra("route", "/");
                startActivity(intent1);
            }
        });
        sendBroadcast(new Intent("matrix.notify"));
    }

    @Override
    public void onNewToken(String token) {
        Log.d(TAG, "Refreshed token: " + token);
    }

   
}