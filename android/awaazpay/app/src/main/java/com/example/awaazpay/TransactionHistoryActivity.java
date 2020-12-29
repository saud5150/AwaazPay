package com.example.awaazpay;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
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
import com.google.gson.Gson;
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

public class TransactionHistoryActivity extends AppCompatActivity implements View.OnClickListener, OnDSListener {
    public final String TAG = "Activity_DroidSpeech";
    boolean isError = false;
    private DroidSpeech droidSpeech;
    private Button start, stop;
    TextToSpeech t1;
    boolean isPaused = false;
    boolean isChecked;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_transaction_history);
        if(MainActivity.loggedIn==false){
            finish();
        }
        isChecked = MainActivity.isChecked;
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
        start = findViewById(R.id.startTransaction);
        start.setOnClickListener(this);
        stop = findViewById(R.id.stopTransaction);
        stop.setOnClickListener(this);

        try {
            RequestQueue requestQueue = Volley.newRequestQueue(this);
            String URL = "https://hbutt877.pythonanywhere.com/transactionhistory";
            JSONObject jsonBody = new JSONObject();
            jsonBody.put("username", HomeActivity.username);
            Long seconds = null;
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                seconds = Instant.now().getEpochSecond();
            }
            else{
                seconds = Calendar.getInstance().getTimeInMillis()/1000l;
            }
            try {
                jsonBody.put("key", Encrypt.encrypt("hassan", "butt", seconds.toString()));
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
                    Gson gson = new Gson();
                    TransactionData[] listObject = gson.fromJson(response, TransactionData[].class);
                    if(listObject!=null && listObject.length>0){
                        List<TransactionData> transactionDataList = new ArrayList<>();
                        for(int i=0;i<listObject.length;i++){
                            transactionDataList.add(listObject[i]);
                        }
                        ListView listView = findViewById(R.id.listview);
                        TransactionDataAdapter transactionDataAdapter = new TransactionDataAdapter(TransactionHistoryActivity.this, R.layout.transaction_data, transactionDataList);
                        listView.setAdapter(transactionDataAdapter);
                    }
                    else{
                        Toast.makeText(TransactionHistoryActivity.this, "ERROR", Toast.LENGTH_SHORT).show();
                    }
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
    protected void onResume() {
        super.onResume();
        if (isChecked) {
            isPaused = false;
            start.post(new Runnable() {
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
    public void onClick(View view) {
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
            Speak("back button is clicked");
            onBackPressed();
            return;
        }
        else if(finalSpeechResult.contains("help")){
//            Speak("This is the home screen. " +
//                    "to send money, say \"send money\". " +
//                    "to pay your bills, say \"pay bills\"" +
//                    "to logout, say \"logout\"");
//            return;
        }
        else if(finalSpeechResult.contains("exit")){
            Speak("Good bye");
            this.finishAffinity();
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
    class TransactionDataAdapter extends ArrayAdapter<TransactionData> {

        private int layoutResource;

        public TransactionDataAdapter(Context context, int layoutResource, List<TransactionData> transactionDataList) {
            super(context, layoutResource, transactionDataList);
            this.layoutResource = layoutResource;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {

            View view = convertView;

            if (view == null) {
                LayoutInflater layoutInflater = LayoutInflater.from(getContext());
                view = layoutInflater.inflate(layoutResource, null);
            }

            TransactionData transactionData = getItem(position);

            if (transactionData != null) {
                TextView date = view.findViewById(R.id.dateTransaction);
                TextView username = view.findViewById(R.id.usernameTransaction);
                TextView amount = view.findViewById(R.id.amountTransaction);
                TextView type = view.findViewById(R.id.typeTransaction);
                if (username != null) {
                    username.setText(transactionData.getUsername());
//                    Speak("Username: "+transactionData.getUsername());
                }
                if (amount != null) {
                    amount.setText("Rs. "+transactionData.getAmount());
//                    Speak("Amount: "+transactionData.getAmount());
                }
                if (type != null) {
                    type.setText(transactionData.getType());
//                    Speak("Type: "+transactionData.getType());
                }
                if (date != null) {
                    date.setText(transactionData.getDate());
//                    Speak("Date: "+transactionData.getDate());
                }
            }

            return view;
        }
    }
}














































class TransactionData {
    private String date;
    private String username;
    private String amount;
    private String type;

    public TransactionData(String date, String username, String amount,String type) {
        this.date = date;
        this.username = username;
        this.amount = amount;
        this.type = type;
    }

    public String getDate() {
        return date;
    }

    public String getUsername() {
        return username;
    }

    public String getAmount() {
        return amount;
    }

    public String getType() {
        return type;
    }
}

