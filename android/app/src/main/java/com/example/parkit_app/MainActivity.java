package com.justpark.it.app;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private MyReceiver receiver;
  
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        receiver = new MyReceiver(new Handler(),flutterEngine); // Create the receiver
        registerReceiver(receiver, new IntentFilter("matrix.notify")); // Register receiver
    }
    public static class MyReceiver extends BroadcastReceiver {
        private final Handler handler;
        private final FlutterEngine flutterEngine;
        public MyReceiver(Handler handler,FlutterEngine flutterEngine) {
            this.handler = handler;
            this.flutterEngine=flutterEngine;
        }
        @Override
        public void onReceive(final Context context, Intent intent) {
            handler.post(new Runnable() {
                @Override
                public void run() {
                    updateFlutter(flutterEngine);
                }
            });
        }
        void updateFlutter(FlutterEngine flutterEngine){
            new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "matrix/notify")
                    .invokeMethod("notificationUpdate", null, new MethodChannel.Result() {
                        @Override
                        public void success(Object o) {
                        }
                        @Override
                        public void error(String s, String s1, Object o) {
                        }
                        @Override
                        public void notImplemented() {
                        }

                    });
        }
    }
}
