package com.example.awaazpay;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import android.content.DialogInterface;
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

public class SendMoneyActivity extends AppCompatActivity implements View.OnClickListener, OnDSListener {

    public final String TAG = "Activity_DroidSpeech";
    boolean isError = false;
    private DroidSpeech droidSpeech;
    private Button start,stop,sendButton;
    EditText username,amount,currentEditText;
    TextToSpeech t1;
    boolean isPaused = false;
    boolean isChecked;
    private ProgressBar spinner;
    AlertDialog.Builder builder;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

        // Setting the layout;[.
        setContentView(R.layout.activity_send_money);
        if(MainActivity.loggedIn==false){
            finish();
        }
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
        start = findViewById(R.id.startSendMoney);
        start.setOnClickListener(this);
        stop = findViewById(R.id.stopSendMoney);
        stop.setOnClickListener(this);
        sendButton = findViewById(R.id.sendButtonSendMoney);
        sendButton.setOnClickListener(this);
        username = findViewById(R.id.usernameSendMoney);
        username.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View view, boolean hasFocus) {
                if (hasFocus) {
                    currentEditText = username;
                    Speak("username is selected");
                }
            }
        });
        amount = findViewById(R.id.amountSendMoney);
        amount.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View view, boolean hasFocus) {
                if (hasFocus) {
                    currentEditText = amount;
                    Speak("amount is selected");
                }
            }
        });
        spinner = findViewById(R.id.progressBarSendMoney);
        spinner.setVisibility(View.GONE);
        builder = new AlertDialog.Builder(this);
    }
    CharSequence getSpeakable(EditText current){
        char[] characters = current.getText().toString().toLowerCase().toCharArray();
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

    @Override
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.sendButtonSendMoney:
                sendButton.setEnabled(false);
                spinner.setVisibility(View.VISIBLE);
                if(username.getText().toString().equals("") ){
                    Speak("Username cannot be empty");
                    builder.setMessage("Username cannot be empty").setTitle("ERROR");
                    builder.create().show();
                    sendButton.setEnabled(true);
                    spinner.setVisibility(View.GONE);
                    break;
                }
                if(amount.getText().toString().equals("")){
                    Speak("amount cannot be empty");
                    builder.setMessage("Amount cannot be empty").setTitle("ERROR");
                    builder.create().show();
                    sendButton.setEnabled(true);
                    spinner.setVisibility(View.GONE);
                    break;
                }
                if(username.getText().toString().equals(HomeActivity.username)){
                    Speak("cannot send money to yourself");
                    builder.setMessage("Cannot send money to yourself").setTitle("ERROR");
                    builder.create().show();
                    sendButton.setEnabled(true);
                    spinner.setVisibility(View.GONE);
                    break;
                }
                try {
                    RequestQueue requestQueue = Volley.newRequestQueue(this);
                    String URL = "https://hbutt877.pythonanywhere.com/sendmoney";
                    JSONObject jsonBody = new JSONObject();
                    jsonBody.put("fromusername", HomeActivity.username);
                    jsonBody.put("tousername", username.getText().toString().toLowerCase());
                    jsonBody.put("amount", amount.getText().toString());
                    Long seconds = null;
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                        seconds = Instant.now().getEpochSecond();
                    }
                    else{
                        seconds = Calendar.getInstance().getTimeInMillis()/1000l;
                    }                    try {
                    jsonBody.put("key", Encrypt.encrypt("hassan","butt",seconds.toString()));
                    Log.i("VOLLEY", jsonBody.toString());
                    } catch (Exception e) {
                        Log.i("VOLLEY", e.toString());
                        e.printStackTrace();
                    }
                    final String requestBody = jsonBody.toString();
                    StringRequest stringRequest = new StringRequest(Request.Method.POST, URL, new Response.Listener<String>() {
                        @Override
                        public void onResponse(String response) {
                            Log.i("VOLLEY", response);
                            if(response.equals("success")){
                                Speak("money sent successfully");
                                Toast.makeText(SendMoneyActivity.this, "Money sent successfully.", Toast.LENGTH_LONG).show();
                                finish();
                            }
                            else if(response.equals("incorrect amount")){
                                Speak("incorrect amount");
                                builder.setMessage("Incorrect amount").setTitle("ERROR");
                                builder.create().show();
                            }
                            else if(response.equals("low balance")){
                                Speak("low balance");
                                builder.setMessage("Low Balance").setTitle("ERROR");
                                builder.create().show();
                            }
                            else{
                                Speak("Error");
                                builder.setMessage("Error").setTitle("ERROR");
                                builder.create().show();
                            }
                            sendButton.setEnabled(true);
                            spinner.setVisibility(View.GONE);
                        }
                    }, new Response.ErrorListener() {
                        @Override
                        public void onErrorResponse(VolleyError error) {
                            Log.e("VOLLEY", error.toString());
                            builder.setMessage("ERROR").setTitle("ERROR");
                            builder.create().show();
                            sendButton.setEnabled(true);
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
                    builder.setMessage("ERROR").setTitle("ERROR");
                    builder.create().show();
                    sendButton.setEnabled(true);
                    spinner.setVisibility(View.GONE);
                }
                Speak("send money clicked");
                break;
        }
    }


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

    }
    @Override
    public void onDroidSpeechFinalResult(String finalSpeechResult)
    {
        Log.i("finalspeech", "Final speech result = " + finalSpeechResult);
        isError = false;
        finalSpeechResult = finalSpeechResult.replaceAll("[ ,]", "");
        finalSpeechResult = finalSpeechResult.toLowerCase();
        if(finalSpeechResult.contains("back")){
            Speak("back button is clicked");
            onBackPressed();
            return;
        }
        else if(finalSpeechResult.contains("help")){
            Speak("to type username of receiver, say \"select username\". " +
                    "to type the amount you want to send, say \"select amount\". " +
                    "to send money, say \"send money\"");
            return;
        }
        else if(finalSpeechResult.contains("exit")){
            Speak("Good bye");
            this.finishAffinity();
            return;
        }
        if(finalSpeechResult.contains("username")){
            username.requestFocus();
            return;
        }
        else if(finalSpeechResult.contains("amount")){
            amount.requestFocus();
            return;
        }
        if (currentEditText == null) {
            Speak("Please Select Username or Amount");
            return;
        }
        if(finalSpeechResult.contains("send")){
            if(finalSpeechResult.contains("money")){
                sendButton.performClick();
                return;
            }
        }
        else if(finalSpeechResult.equals("delete") || finalSpeechResult.equals("remove") || finalSpeechResult.equals("backspace")){
            String s = currentEditText.getText().toString();
            if(s.isEmpty()){
                if(currentEditText.equals(username)){
                    Speak("Username is Empty");
                }
                else if(currentEditText.equals(amount)){
                    Speak("Amount is Empty");
                }            }
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
            else if(currentEditText.equals(amount)){
                Speak("amount is Empty");
            }
        }
        else if(finalSpeechResult.contains("speak")) {
            if(currentEditText.equals(username)) {
                if (currentEditText.getText().length()>0){
                    Speak("You have typed username, " + getSpeakable(username));
                }
                else{
                    Speak("username is empty");
                }
            }
            else if(currentEditText.equals(amount)){
                if (currentEditText.getText().length()>0){
                    Speak("You have typed amount, "+getSpeakable(amount));
                }
                else{
                    Speak("amount is empty");
                }
            }

        }
        else{
            if(finalSpeechResult.contains("type") || finalSpeechResult.contains("select")){
                if(finalSpeechResult.length()>5) {
                    currentEditText.setText(currentEditText.getText().toString().concat(finalSpeechResult.substring(4)));
                }
            }
            else {
                currentEditText.setText(currentEditText.getText().toString().concat(finalSpeechResult));
            }
            Speak(getSpeakable(currentEditText));
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