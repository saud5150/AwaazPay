package com.example.awaazpay;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.Toast;

import com.android.volley.AuthFailureError;
import com.android.volley.NetworkResponse;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.VolleyLog;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.vikramezhil.droidspeech.DroidSpeech;
import com.vikramezhil.droidspeech.OnDSListener;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Locale;

public class SigninActivity extends AppCompatActivity implements View.OnClickListener, OnDSListener{
    public final String TAG = "Activity_DroidSpeech";
    boolean isError = false;
    private DroidSpeech droidSpeech;
    private Button start, stop,signinButton;
    TextToSpeech t1;
    EditText username,password;
    EditText currentEditText;
    boolean isPaused = false;
    boolean isChecked;
    private ProgressBar spinner;
    AlertDialog.Builder builder;
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

        // Setting the layout;[.
        setContentView(R.layout.activity_signin);
//        setContentView(R.layout.activity_signin);
        isChecked = MainActivity.isChecked;

        // Initializing the droid speech and setting the listener
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
        start = findViewById(R.id.startSignin);
        start.setOnClickListener(this);
        stop = findViewById(R.id.stopSignin);
        stop.setOnClickListener(this);
        username = findViewById(R.id.usernameSignin);
        username.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View view, boolean hasFocus) {
                if (hasFocus) {
                    currentEditText = username;
                    Speak("username is selected");
                }
            }
        });
        password = findViewById(R.id.passwordSignin);
        password.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View view, boolean hasFocus) {
                if (hasFocus) {
                    currentEditText = password;
                    Speak("password is selected");
                }
            }
        });
        signinButton = findViewById(R.id.signinButton);
        signinButton.setOnClickListener(this);
        spinner = findViewById(R.id.progressBarSignin);
        spinner.setVisibility(View.GONE);
        builder = new AlertDialog.Builder(this);
    }
    void Speak(CharSequence charSpeak){
//        mSpeechRecognizer.stopListening();
        if(!isChecked){
            return;
        }
        droidSpeech.closeDroidSpeechOperations();
        t1.speak(charSpeak, TextToSpeech.QUEUE_ADD, null, null);
        if(isPaused){
            return;
        }
        start.post(new Runnable()
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
    CharSequence getSpeakable(){
        char[] characters = currentEditText.getText().toString().toLowerCase().toCharArray();
        ArrayList<Character> toSpeak = new ArrayList<>();
        for(int i=0;i<characters.length;i+=1){
            if(i==characters.length-1){
                toSpeak.add(characters[i]);
            }
            else{
                toSpeak.add(characters[i]);
                toSpeak.add(' ');
            }
        }
        String s = "";
        for(int i=0;i<toSpeak.size();i+=1){
            s = s.concat(toSpeak.get(i).toString());
        }
        return s;
    }
    @Override
    protected void onResume()
    {
        super.onResume();
        if(!isChecked){
            return;
        }
        isPaused = false;
        start.post(new Runnable()
        {
            @Override
            public void run()
            {
                droidSpeech.startDroidSpeechRecognition();
            }
        });
    }

    @Override
    protected void onPause()
    {
        super.onPause();
        if(!isChecked){
            return;
        }
        isPaused = true;
        droidSpeech.closeDroidSpeechOperations();


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


//    @Override
//    public void onFocusChange(View view, boolean hasFocus) {
//        switch (view.getId()) {
//            case R.id.usernameSignin:
//                if (hasFocus) {
//                    currentEditText = username;
//                    Speak("username is selected");
//                }
//            case R.id.passwordSignin:
//                if (hasFocus) {
//                    currentEditText = password;
//                    Speak("password is selected");
//                }
//        }
//    }

    @Override
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.signinButton:
                signinButton.setEnabled(false);
                spinner.setVisibility(View.VISIBLE);
                if(username.getText().toString().equals("") ){
                    Speak("Username cannot be empty");
                    builder.setMessage("Username cannot be empty").setTitle("ERROR");
                    builder.create().show();
                    signinButton.setEnabled(true);
                    spinner.setVisibility(View.GONE);
                    break;
                }
                if(password.getText().toString().equals("")){
                    Speak("password cannot be empty");
                    builder.setMessage("Password cannot be empty").setTitle("ERROR");
                    builder.create().show();
                    signinButton.setEnabled(true);
                    spinner.setVisibility(View.GONE);
                    break;
                }
                try {
                    RequestQueue requestQueue = Volley.newRequestQueue(this);
                    String URL = "https://hbutt877.pythonanywhere.com/signin";
                    JSONObject jsonBody = new JSONObject();
                    Long seconds = null;
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                        seconds = Instant.now().getEpochSecond();
                    }
                    else{
                        seconds = Calendar.getInstance().getTimeInMillis()/1000l;
                    }
                    jsonBody.put("username", username.getText().toString().toLowerCase());
                    jsonBody.put("password", password.getText());
                    try {
                        jsonBody.put("key", Encrypt.encrypt("hassan","butt",seconds.toString()));
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    final String requestBody = jsonBody.toString();
                    StringRequest stringRequest = new StringRequest(Request.Method.POST, URL, new Response.Listener<String>() {
                        @Override
                        public void onResponse(String response) {
                            Log.i("VOLLEY", response);
                            if(response.equals("account login sccuessfully")){
                                Speak("Account logged in successfully");
                                MainActivity.loggedIn = true;
                                Intent homeIntent = new Intent(SigninActivity.this,HomeActivity.class);
                                homeIntent.putExtra("username",username.getText().toString().toLowerCase());
                                homeIntent.putExtra("password",password.getText().toString());
                                startActivity(homeIntent);
                                finish();
                                return;
                            }
                            else if(response.equals("wrong username or password")){
                                Speak("wrong username or password");
                                builder.setMessage("Wrong Username or Password").setTitle("ERROR");
                                builder.create().show();
                            }
                            else if(response.equals("Please confirm your email first.")){
                                Speak("Please confirm your email first.");
                                builder.setMessage("Please confirm your email first.").setTitle("ERROR");
                                builder.create().show();
                            }
                            else{
                                Speak("Error");
                                builder.setMessage("Error").setTitle("ERROR");
                                builder.create().show();
                            }
                            signinButton.setEnabled(true);
                            spinner.setVisibility(View.GONE);
                        }
                    }, new Response.ErrorListener() {
                        @Override
                        public void onErrorResponse(VolleyError error) {
                            Log.e("VOLLEY", error.toString());
                            builder.setMessage("Error").setTitle("ERROR");
                            builder.create().show();
                            signinButton.setEnabled(true);
                            spinner.setVisibility(View.GONE);
                        }
                    }) {
                        @Override
                        public String getBodyContentType() {
                            return "application/json; charset=utf-8";
                        }
                        @Override
                        public byte[] getBody() throws AuthFailureError {
                            try {
                                return requestBody == null ? null : requestBody.getBytes("utf-8");
                            } catch (UnsupportedEncodingException uee) {
                                VolleyLog.wtf("Unsupported Encoding while trying to get the bytes of %s using %s", requestBody, "utf-8");
                                return null;
                            }
                        }

                        @Override
                        protected Response<String> parseNetworkResponse(NetworkResponse response) {
                            String responseString = "";
                            if (response != null) {
                                responseString = String.valueOf(response.statusCode);
                                // can get more details such as response.headers
                            }
                            return super.parseNetworkResponse(response);
//                            return Response.success(responseString, HttpHeaderParser.parseCacheHeaders(response));
                        }
                    };

                    requestQueue.add(stringRequest);
                } catch (JSONException e) {
                    e.printStackTrace();
                    builder.setMessage("Error").setTitle("ERROR");
                    builder.create().show();
                    signinButton.setEnabled(true);
                    spinner.setVisibility(View.GONE);
                }
                Speak("sign in is clicked");
                break;
        }
    }

    // MARK: DroidSpeechListener Methods

    @Override
    public void onDroidSpeechSupportedLanguages(String currentSpeechLanguage, List<String> supportedSpeechLanguages)
    {
        Log.i(TAG, "Current speech language = " + currentSpeechLanguage);
        Log.i(TAG, "Supported speech languages = " + supportedSpeechLanguages.toString());

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

//        if(finalSpeechResult.isEmpty()) {
//            Speak("Please Try Again");
//            return;
//        }
        isError = false;
        finalSpeechResult = finalSpeechResult.replaceAll("[ ,]","");
        finalSpeechResult = finalSpeechResult.toLowerCase();
        if(finalSpeechResult.contains("back")){
            onBackPressed();
            return;
        }
        else if(finalSpeechResult.contains("help")){
            Speak("to start typing username, say \"select username\". " +
                    "to start typing password, say \"select password\". " +
                    "to login to your account, say \"login\"");
            return;
        }
        else if(finalSpeechResult.contains("exit")){
            this.finishAffinity();
            return;
        }

        if(finalSpeechResult.contains("password")){
            if(finalSpeechResult.contains("username") && finalSpeechResult.startsWith("pass")) {
                password.requestFocus();
            }
            else if(finalSpeechResult.contains("username") && finalSpeechResult.startsWith("user")){
                username.requestFocus();
            }
            else{
                password.requestFocus();
            }
            return;
        }
        else if(finalSpeechResult.contains("username")){
            username.requestFocus();
            return;
        }




        if (currentEditText == null) {
            Speak("Please Select Username or Password");
            return;
        }
        if(finalSpeechResult.contains("login") || finalSpeechResult.contains("signin")){
            signinButton.performClick();
            return;
        }

        if(finalSpeechResult.equals("delete") || finalSpeechResult.equals("remove") || finalSpeechResult.equals("backspace")){
            String s = currentEditText.getText().toString();
            if(s.isEmpty()){
                if(currentEditText.equals(username)){
                    Speak("Username is Empty");
                }
                else if(currentEditText.equals(password)){
                    Speak("Password is Empty");
                }
            }
            else{
                s = s.substring(0, s.length() - 1);
                currentEditText.setText(s);
            }
        }
        else if(finalSpeechResult.equals("deleteall") || finalSpeechResult.equals("removeall") || finalSpeechResult.equals("backspaceall")){
            currentEditText.setText("");
            if(currentEditText.equals(username)){
                Speak("Username is Empty");
            }
            else if(currentEditText.equals(password)){
                Speak("Password is Empty");
            }
        }
        else if(finalSpeechResult.contains("speak")) {
            if(currentEditText.equals(username)) {
                if (currentEditText.getText().length()>0){
                    Speak("You have typed username, " + getSpeakable());
                }
                else{
                    Speak("username is empty");
                }
            }
            else if(currentEditText.equals(password)){
                if (currentEditText.getText().length()>0){
                    Speak("You have typed password, "+getSpeakable());
                }
                else{
                    Speak("password is empty");
                }
            }
        }
        else{
            if(finalSpeechResult.startsWith("type")){
                if(finalSpeechResult.length()>5) {
                    currentEditText.setText(currentEditText.getText().toString().concat(finalSpeechResult.substring(4)));
                }
            }
            else {
                currentEditText.setText(currentEditText.getText().toString().concat(finalSpeechResult));
            }
            Speak(getSpeakable());
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
        stop.post(new Runnable()
        {
            @Override
            public void run()
            {
                // Stop listening
                droidSpeech.closeDroidSpeechOperations();
            }
        });
        if(isPaused){
            return;
        }
        start.post(new Runnable()
        {
            @Override
            public void run()
            {
                // Start listening
                droidSpeech.startDroidSpeechRecognition();
            }
        });
    }
}