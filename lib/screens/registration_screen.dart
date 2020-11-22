import 'package:awaazpay_v1/utilities/color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:awaazpay_v1/utilities/navigation_router.dart';
import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
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
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => new _RegistrationScreenState();

}
class _RegistrationScreenState extends State<RegistrationScreen> implements View.OnClickListener, OnDSListener{
  public final String TAG = "Activity_DroidSpeech";
  boolean isError = false;
  private DroidSpeech droidSpeech;
  private Button start, stop,signupButton;
  TextToSpeech t1;
  EditText username,password;
  EditText currentEditText;
  boolean isPaused = false;
  boolean isChecked;

  @Override
  protected void onCreate(Bundle savedInstanceState)
  {
      super.onCreate(savedInstanceState);

      // Setting the layout;[.
      setContentView(R.layout.activity_signup);
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
      start = findViewById(R.id.startSendMoney);
      start.setOnClickListener(this);
      stop = findViewById(R.id.stopSendMoney);
      stop.setOnClickListener(this);
      username = findViewById(R.id.usernameSignup);
      password = findViewById(R.id.passwordSignup);
      signupButton = findViewById(R.id.signupButton);
      signupButton.setOnClickListener(this);
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


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
       backgroundColor: colorScheme.WHITE,

      appBar: new AppBar(
        title: new Text('Registration'),
      ),
      body: new Container(
          padding: new EdgeInsets.all(20.0),
          child: new Form(

            child: new ListView(
              children: <Widget>[
                new Container(
                    padding: new EdgeInsets.all(20.0),
                    child:new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                       // FlutterLogo(
                        //  size: 100.0,
                       // ),
                        RichText(
                          text: TextSpan(
                            text: "Awaaz",
                            style: TextStyle(color: colorScheme.BLACK, fontSize: 40),
                            children: <TextSpan>[
                              TextSpan(text: 'Pay', style: TextStyle(color: colorScheme.GREEN)),
                            ],
                          ),
                        ),
                      ],
                    )
                ),
                new Container(
                  //color: colorScheme.WHITE,

                    padding: const EdgeInsets.only(top: 10.0),
                    child: new TextFormField(
                        keyboardType: TextInputType.text, // Use email input type for emails.
                        decoration: new InputDecoration(
                          hintText: 'User Name',
                          labelText: 'Enter Username',
                          icon: new Icon(Icons.person),
                        )

                    )
                ),
                new Container(
                    padding: const EdgeInsets.only(top: 10.0),
                    color: colorScheme.WHITE,
                    child: new TextFormField(
                        keyboardType: TextInputType.emailAddress, // Use email input type for emails.

                        decoration: new InputDecoration(
                            hintText: 'you@example.com',
                            labelText: 'E-mail Address',

                            icon: new Icon(Icons.email))

                    )
                ),
                new Container(
                  padding: const EdgeInsets.only(top:10.0),
                  child:  new TextFormField(
                      obscureText: true, // Use secure text for passwords.
                      decoration: new InputDecoration(
                          hintText: 'Password',
                          labelText: 'Enter Password',
                          icon: new Icon(Icons.lock)

                      )
                  ),
                ),
                new Container(
                  padding: const EdgeInsets.only(top:10.0),
                  child:  new TextFormField(
                      obscureText: true, // Use secure text for passwords.
                      decoration: new InputDecoration(
                          hintText: 'Confirm Password',
                          labelText: 'Confirm password',
                          icon: new Icon(Icons.lock)

                      )
                  ),
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Container(
                      height:50.0,
                      width: 210.0,
                      margin: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 40.0),
                      child: new RaisedButton(
                        child: new Text(
                          'Register',
                          style: new TextStyle(
                              color: Colors.white
                          ),
                        ),
                        onPressed: () => _performLogin(),
                        color: colorScheme.GREEN,
                      ),

                    ),

                  ],
                ),

              ],
            ),
          )
      ),
    );
  }

  _performLogin() {
    @Override
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.signupButton:
                if(username.getText().toString().equals("") ){
                    Speak("Username cannot be empty");
                    break;
                }
                if(password.getText().toString().equals("")){
                    Speak("password cannot be empty");
                    break;
                }
                try {
                    RequestQueue requestQueue = Volley.newRequestQueue(this);
                    String URL = "https://hbutt877.pythonanywhere.com/signup";
                    JSONObject jsonBody = new JSONObject();
                    jsonBody.put("username", username.getText().toString().toLowerCase());
                    jsonBody.put("password", password.getText());
                    final String requestBody = jsonBody.toString();
                    StringRequest stringRequest = new StringRequest(Request.Method.POST, URL, new Response.Listener<String>() {
                        @Override
                        public void onResponse(String response) {
                            Log.i("VOLLEY", response);
                            if(response.equals("account created sccuessfully")){
                                Speak("account signed up successfully");
                                finish();
                            }
                            else if(response.equals("username already exists")){
                                Speak("username already exists");
                            }
                            else{
                                Speak("an error occured");
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
                Speak("sign up is clicked");
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
        else if(finalSpeechResult.contains("exit")){
            this.finishAffinity();
            return;
        }

        if(finalSpeechResult.contains("password")){
            if(finalSpeechResult.contains("username") && finalSpeechResult.startsWith("pass")) {
                currentEditText = password;
                password.requestFocus();
                Speak("password is selected");
            }
            else if(finalSpeechResult.contains("username") && finalSpeechResult.startsWith("user")){
                currentEditText = username;
                username.requestFocus();
                Speak("username is selected");
            }
            else{
                currentEditText = password;
                password.requestFocus();
                Speak("password is selected");
            }
            return;
        }
        else if(finalSpeechResult.contains("username")){
            currentEditText = username;
            username.requestFocus();
            Speak("username is selected");
            return;
        }




        if(currentEditText == null) {
            Speak("Please Select Username or Password");
            return;
        }
        if(finalSpeechResult.contains("signup")){
            Toast.makeText(this,"signup clicked", Toast.LENGTH_SHORT).show();
            return;
        }

        if(finalSpeechResult.equals("delete") || finalSpeechResult.equals("remove") || finalSpeechResult.equals("backspace")){
            String s = currentEditText.getText().toString();
            if(s.isEmpty()){
                Speak("Username is Empty");
            }
            else{
                s = s.substring(0, s.length() - 1);
                currentEditText.setText(s);
            }
        }
        else if(finalSpeechResult.equals("deleteall") || finalSpeechResult.equals("removeall") || finalSpeechResult.equals("backspaceall")){
            currentEditText.setText("");
            if(currentEditText.equals(username)) {
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
            else{
                currentEditText.setText(currentEditText.getText().toString().concat(finalSpeechResult));
            }
            Speak(getSpeakable());
        }
    }

    @Override
    public void onDroidSpeechClosedByUser()
    {

    }

    @Override
    public void onDroidSpeechError(String errorMsg)
    {
        if(!isError) {
            if(errorMsg.contains("busy")){
  //                Toast.makeText(this, errorMsg, Toast.LENGTH_LONG).show();
            }
            else{
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

  _navigateRegistration() {

    NavigationRouter.switchToRegistration(context);
  }
}
