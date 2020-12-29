package com.example.awaazpay;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.Switch;
import android.widget.Toast;

import com.vikramezhil.droidspeech.DroidSpeech;
import com.vikramezhil.droidspeech.OnDSListener;
import com.vikramezhil.droidspeech.OnDSPermissionsListener;

import java.util.List;
import java.util.Locale;

public class MainActivity extends AppCompatActivity implements View.OnClickListener, OnDSListener, OnDSPermissionsListener {

    public final String TAG = "Activity_DroidSpeech";
    static boolean loggedIn = false;
    DroidSpeech droidSpeech;
    private Button signIn,signUp;
    TextToSpeech t1;
    boolean isError = false;
    boolean isPaused = false;
    Switch switchVoice;
    static boolean isChecked;
    SharedPreferences sharedPreferences;
    SharedPreferences.Editor editor;
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_main);
        sharedPreferences = getSharedPreferences("my", this.MODE_PRIVATE);
        isChecked = sharedPreferences.getBoolean("isChecked",true);
        editor = sharedPreferences.edit();
        droidSpeech = new DroidSpeech(this, getFragmentManager());
        droidSpeech.setOnDroidSpeechListener(this);

        t1 = new TextToSpeech(getApplicationContext(), new TextToSpeech.OnInitListener() {
            @Override
            public void onInit(int status) {
                if (status != TextToSpeech.ERROR) {
                    t1.setLanguage(Locale.ENGLISH);
                }
                }
        });
        signIn = findViewById(R.id.signinMain);
        signUp = findViewById(R.id.signupMain);
        signIn.setOnClickListener(this);
        signUp.setOnClickListener(this);
        switchVoice = findViewById(R.id.switchMainActivity);
        switchVoice.setOnClickListener(this);
        switchVoice.setChecked(isChecked);
    }
    void Speak(CharSequence charSpeak){
//        mSpeechRecognizer.stopListening();
//        if(isChecked) {
//            droidSpeech.closeDroidSpeechOperations();
//            t1.speak(charSpeak, TextToSpeech.QUEUE_ADD, null, null);
//        }
        if(!isChecked){
            return;
        }
        droidSpeech.closeDroidSpeechOperations();
        t1.speak(charSpeak, TextToSpeech.QUEUE_ADD, null, null);
        if(isPaused){
            return;
        }
        signIn.post(new Runnable()
        {
            @Override
            public void run()
            {
                while(t1.isSpeaking()){
                }
                droidSpeech.startDroidSpeechRecognition();
            }
        });

    }
    @Override
    protected void onResume()
    {
        super.onResume();
        if(isChecked) {
            isPaused = false;
            signIn.post(new Runnable() {
                @Override
                public void run() {
                    droidSpeech.startDroidSpeechRecognition();
                }
            });
        }
    }

    @Override
    protected void onPause()
    {
        super.onPause();
        if(isChecked) {
            droidSpeech.closeDroidSpeechOperations();
            isPaused = true;
        }

    }

    @Override
    protected void onDestroy()
    {
        super.onDestroy();
        if(!isChecked){
            return;
        }
        droidSpeech.closeDroidSpeechOperations();

    }

    // MARK: OnClickListener Method

    @Override
    public void onClick(View view)
    {
        switch (view.getId())
        {
            case R.id.signupMain:
                Speak("proceeding to signup screen");
                Intent signupIntent = new Intent(MainActivity.this,SignupActivity.class);
                startActivity(signupIntent);
                break;

            case R.id.signinMain:
                Speak("proceeding to signin screen");
                Intent signinIntent = new Intent(MainActivity.this,SigninActivity.class);
                startActivity(signinIntent);
                break;
            case R.id.switchMainActivity:
                if(switchVoice.isChecked()){
                    isChecked = true;
                    isPaused = false;
                    signIn.post(new Runnable()
                    {
                        @Override
                        public void run()
                        {
                            if(droidSpeech!=null) {
                                droidSpeech.startDroidSpeechRecognition();
                            }
                        }
                    });
                }
                else{
                    isChecked = false;
                    if(droidSpeech!=null) {
                        droidSpeech.closeDroidSpeechOperations();
                    }
                    isPaused = true;
                }
                editor.putBoolean("isChecked",isChecked);
                editor.commit();
        }
    }

    @Override
    public void onDroidSpeechSupportedLanguages(String currentSpeechLanguage, List<String> supportedSpeechLanguages)
    {
        if(supportedSpeechLanguages.contains("ur-PK"))
        {
//            droidSpeech.setPreferredLanguage("ur-PK");
        }
    }

    @Override
    public void onDroidSpeechRmsChanged(float rmsChangedValue)
    {
        // Log.i(TAG, "Rms change value = " + rmsChangedValue);
    }

    @Override
    public void onDroidSpeechLiveResult(String liveSpeechResult)
    {
        Log.i(TAG, "Live speech result = " + liveSpeechResult);
    }

    @Override
    public void onDroidSpeechFinalResult(String finalSpeechResult)
    {
        finalSpeechResult = finalSpeechResult.replaceAll("[ ,]","");
        finalSpeechResult = finalSpeechResult.toLowerCase();
        if(finalSpeechResult.contains("back")){
            onBackPressed();
            return;
        }
        else if(finalSpeechResult.contains("help")){
            Speak("to proceed to login screen, say \"login\". " +
                    "to proceed to signup screen, say \"signup\"." +
                    "to start tutorial, say \"tutorial\"");
            return;
        }
        else if(finalSpeechResult.contains("tutorial")){
            Speak("Hello, Welcome to Awaaz Pay. Here are the typing guidelines." +
                    "You can type character by character as well as word by word." +
                    "To delete a character, say \"delete\". To delete all characters, say \"delete all\"." +
                    "To check the characters you have written, say \"speak\". " +
                    "Here are the general guidelines." +
                    "To get help about any page, say \"help\" on that page." +
                    "To click back button, say, \"back\". To exit the app, say \"exit\"." +
                    "You can always access this tutorial from this page by saying, \"tutorial\".");
            return;
        }

        else if(finalSpeechResult.contains("exit")){
            this.finishAffinity();
            return;
        }
        if(finalSpeechResult.contains("signup")){
            if((finalSpeechResult.contains("signin") || finalSpeechResult.contains("login")) && (finalSpeechResult.startsWith("signin") || finalSpeechResult.startsWith("login"))) {
                signIn.performClick();
//                Speak("proceeding to signin screen");
            }
            else if((finalSpeechResult.contains("signin") || finalSpeechResult.contains("login")) && finalSpeechResult.startsWith("signup")){
                signUp.performClick();
//                Speak("proceeding to signup screen");
            }
            else{
                signUp.performClick();
//                Speak("proceeding to signup screen");
            }
            return;
        }
        else if(finalSpeechResult.contains("signin") || finalSpeechResult.contains("login")){
            signIn.performClick();
//            Speak("proceeding to signin screen");
        }
    }

    @Override
    public void onDroidSpeechClosedByUser()
    {
//        stop.setVisibility(View.GONE);
//        start.setVisibility(View.VISIBLE);
    }

    @Override
    public void onDroidSpeechError(String errorMsg)
    {
        if(!isError) {
            if(errorMsg.contains("busy")){
//                Toast.makeText(this, errorMsg, Toast.LENGTH_LONG).show();
            }
            else {
                // Speech error
                Toast.makeText(this, errorMsg, Toast.LENGTH_LONG).show();
                t1.speak(errorMsg, TextToSpeech.QUEUE_FLUSH, null, null);
                isError = true;
            }
        }
        signIn.post(new Runnable()
        {
            @Override
            public void run()
            {
                droidSpeech.closeDroidSpeechOperations();
            }
        });
        if(isPaused){
            return;
        }
        signIn.post(new Runnable()
        {
            @Override
            public void run()
            {
                // Start listening
                droidSpeech.startDroidSpeechRecognition();
            }
        });

    }

    // MARK: DroidSpeechPermissionsListener Method

    @Override
    public void onDroidSpeechAudioPermissionStatus(boolean audioPermissionGiven, String errorMsgIfAny)
    {
        if(audioPermissionGiven)
        {
        }
        else
        {
            if(errorMsgIfAny != null)
            {
                // Permissions error
                Toast.makeText(this, errorMsgIfAny, Toast.LENGTH_LONG).show();
                Speak(errorMsgIfAny);
            }

            signIn.post(new Runnable()
            {
                @Override
                public void run()
                {
                    // Stop listening
                    droidSpeech.closeDroidSpeechOperations();
                }
            });
        }
    }
}
