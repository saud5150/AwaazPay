package com.example.awaazpay;

import androidx.appcompat.app.AppCompatActivity;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
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
import java.util.Calendar;
import java.util.List;
import java.util.Locale;

public class HomeActivity extends AppCompatActivity implements View.OnClickListener, OnDSListener {

    public final String TAG = "Activity_DroidSpeech";
    boolean isError = false;
    private DroidSpeech droidSpeech;
    private Button start, stop,sendmoney,paybill,transactions,logout;
    TextToSpeech t1;
    boolean isPaused = false;
    static String username,password;
    TextView balance;
    boolean isChecked;
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        // Setting the layout;[.
        setContentView(R.layout.activity_home);
        if(MainActivity.loggedIn==false){
            finish();
        }
        username = getIntent().getStringExtra("username");
        password = getIntent().getStringExtra("password");
        // Initializing the droid speech and setting the listener
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
        start = findViewById(R.id.startHome);
        start.setOnClickListener(this);
        stop = findViewById(R.id.stopHome);
        stop.setOnClickListener(this);
        sendmoney= findViewById(R.id.sendmoney);
        sendmoney.setOnClickListener(this);
        paybill = findViewById(R.id.paybill);
        paybill.setOnClickListener(this);
        transactions = findViewById(R.id.transactions);
        transactions.setOnClickListener(this);
        logout = findViewById(R.id.logout);
        logout.setOnClickListener(this);
        balance = findViewById(R.id.balanceHomeActivity);
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
        if(isChecked){
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
        @SuppressLint("StaticFieldLeak") AsyncTask<Void, Void, String> asyncTask = new AsyncTask<Void, Void, String>() {
            @Override
            protected String doInBackground(Void... params) {
                try {
                    RequestQueue requestQueue = Volley.newRequestQueue(getApplicationContext());
                    String URL = "https://hbutt877.pythonanywhere.com/fetchbalance";
                    JSONObject jsonBody = new JSONObject();
                    jsonBody.put("username", username);
                    Long seconds = null;
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                        seconds = Instant.now().getEpochSecond();
                    }
                    else{
                        seconds = Calendar.getInstance().getTimeInMillis()/1000l;
                    }
                    try {
                        jsonBody.put("key", Encrypt.encrypt("hassan","butt",seconds.toString()));
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
//            jsonBody.put("password", password);
                    final String requestBody = jsonBody.toString();
                    StringRequest stringRequest = new StringRequest(Request.Method.POST, URL, new Response.Listener<String>() {
                        @Override
                        public void onResponse(String response) {
                            balance.setText("Rs. "+response);
                        }
                    }, new Response.ErrorListener() {
                        @Override
                        public void onErrorResponse(VolleyError error) {
                            Log.e("VOLLEY", error.toString());
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
                }
                return "";
            }

            @Override
            protected void onPostExecute(String result) {
                super.onPostExecute(result);
            }
        };
        asyncTask.execute();
        balance.setText("loading");
    }

    @Override
    protected void onPause()
    {
        super.onPause();
        if(isChecked) {
            isPaused = true;
            droidSpeech.closeDroidSpeechOperations();
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
    @Override
    public void onBackPressed()
    {
//        super.onBackPressed();
//        finishAffinity();
        Intent setIntent = new Intent(Intent.ACTION_MAIN);
        setIntent.addCategory(Intent.CATEGORY_HOME);
        setIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(setIntent);
    }

    // MARK: OnClickListener Method

    @Override
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.sendmoney:
                Speak("proceeding to send money screen");
//                Toast.makeText(this, "send money clicked", Toast.LENGTH_SHORT).show();
                Intent homeIntent = new Intent(HomeActivity.this,SendMoneyActivity.class);
                startActivity(homeIntent);
                break;
            case R.id.paybill:
                Speak("proceeding to pay bills screen");
//                Toast.makeText(this, "pay bill clicked", Toast.LENGTH_SHORT).show();
                Intent billIntent = new Intent(HomeActivity.this,PayBillActivity.class);
                startActivity(billIntent);
                break;
            case R.id.transactions:
                Speak("proceeding to transactions history");
//                Toast.makeText(this, "transactions history clicked", Toast.LENGTH_SHORT).show();
                Intent transactionHistoryIntent = new Intent(HomeActivity.this,TransactionHistoryActivity.class);
                startActivity(transactionHistoryIntent);
                break;
            case R.id.logout:
                Speak("logged out successfully");
                Toast.makeText(this, "logged out successfully", Toast.LENGTH_SHORT).show();
                finish();
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
        finalSpeechResult = finalSpeechResult.replaceAll("[ ,]","");
        finalSpeechResult = finalSpeechResult.toLowerCase();
        if(finalSpeechResult.contains("back")){
//            Speak("back button is clicked");
//            onBackPressed();
            return;
        }
        else if(finalSpeechResult.contains("help")){
            Speak("This is the home screen. " +
                    "to send money, say \"send money\". " +
                    "to pay your bills, say \"pay bills\"" +
                    "to check transactions history, say \"transactions\"" +
                    "to logout, say \"logout\"");
            return;
        }
        else if(finalSpeechResult.contains("logout")){
            finish();
//            finish();
            return;
        }
        else if(finalSpeechResult.contains("exit")){
            Speak("Good bye");
            this.finishAffinity();
            return;
        }

        if(finalSpeechResult.contains("bill") && finalSpeechResult.contains("bill")){
            paybill.performClick();
            return;
        }
        else if(finalSpeechResult.contains("send") && finalSpeechResult.contains("money")){
            sendmoney.performClick();
            return;
        }
        else if(finalSpeechResult.contains("transaction")){
            transactions.performClick();
            return;
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


