import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:awaazpay_v1/utilities/constants.dart';
import 'package:awaazpay_v1/utilities/navigation_router.dart';
import 'package:awaazpay_v1/utilities/color_scheme.dart';
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
import com.android.volley.toolbox.HttpHeaderParser;
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
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;
  public final String TAG = "Activity_DroidSpeech";
  boolean isError = false;
  private DroidSpeech droidSpeech;
  private Button start, stop,signinButton;
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
      setContentView(R.layout.activity_signin);
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
      start = findViewById(R.id.start);
      start.setOnClickListener(this);
      stop = findViewById(R.id.stop);
      stop.setOnClickListener(this);
      username = findViewById(R.id.usernameSignin);
      password = findViewById(R.id.passwordSignin);
      signinButton = findViewById(R.id.signinButton);
      signinButton.setOnClickListener(this);
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


  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          //decoration: kBoxDecorationStyle,
          decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.GREEN,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          height: 60.0,
         // color: colorScheme.GREEN,

          child: TextField(
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: colorScheme.WHITE,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: colorScheme.WHITE,
              ),
              hintText: 'Enter your Email',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          //decoration: kBoxDecorationStyle,
          decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.GREEN,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          height: 60.0,
          //color: colorScheme.GREEN,
          child: TextField(
            obscureText: true,
            style: TextStyle(
              color: colorScheme.WHITE,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),

              prefixIcon: Icon(
                Icons.lock,
                color: colorScheme.WHITE,
              ),
              hintText: 'Enter your Password',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: FlatButton(
        onPressed: () => print('Forgot Password Button Pressed'),
        padding: EdgeInsets.only(right: 0.0),
        child: Text(
          'Forgot Password?',
          style: kLabelStyle,
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Container(
      height: 20.0,
      child: Row(
        children: <Widget>[
          Theme(
            data: ThemeData(unselectedWidgetColor: colorScheme.WHITE),
            child: Checkbox(
              value: _rememberMe,
              checkColor: Colors.green,
              activeColor: colorScheme.WHITE,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value;
                });
              },
            ),
          ),
          Text(
            'Remember me',
            style: kLabelStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        // onPressed: () => print('Login Button Pressed'),
        onPressed: () => _navigateHomePage(),
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: colorScheme.GREEN,
        child: Text(
          'LOGIN',
          style: TextStyle(
            color: colorScheme.WHITE,
            letterSpacing: 1.5,
            fontSize: 18.0,
            //fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
          ),
        ),
      ),
    );
  }

  Widget _buildSignInWithText() {
    return Column(
      children: <Widget>[
        Text(
          '- OR -',
          style: TextStyle(
            color: colorScheme.WHITE,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 20.0),
        Text(
          'Sign in with',
          style: kLabelStyle,
        ),
      ],
    );
  }

  Widget _buildSocialBtn(Function onTap, AssetImage logo) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.0,
        width: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.WHITE,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
          image: DecorationImage(
            image: logo,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialBtnRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildSocialBtn(
                () => print('Login with Facebook'),
            AssetImage(
              'assets/logos/facebook.jpg',
            ),
          ),
          _buildSocialBtn(
                () => print('Login with Google'),
            AssetImage(
              'assets/logos/google.jpg',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupBtn() {
    return GestureDetector(
     // onTap: () => print('Sign Up Button Pressed'),
      onTap: _navigateRegistration,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Don\'t have an Account? ',
              style: TextStyle(
                color: colorScheme.WHITE,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                color: colorScheme.GREEN,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xDD000000),
                      Color(0xDD000000),
                      Color(0xDD000000),
                      Color(0xDD000000),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 120.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Image.asset('assets/logos/awaazpay.jpg'),
                  RichText(
                  text: TextSpan(
                    text: "Awaaz",
                    style: TextStyle(color: colorScheme.WHITE, fontSize: 40),
                    children: <TextSpan>[
                      TextSpan(text: 'Pay', style: TextStyle(color: colorScheme.GREEN)),
                    ],
                  ),
                ),
                      Text(
                        '\n\nSign In',
                        style: TextStyle(
                          color: colorScheme.WHITE,
                          fontFamily: 'Arial',
                          fontSize: 30.0,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30.0),
                      _buildEmailTF(),
                      SizedBox(
                        height: 30.0,
                      ),
                      _buildPasswordTF(),
                      _buildForgotPasswordBtn(),
                      _buildRememberMeCheckbox(),
                      _buildLoginBtn(),
                  //    _buildSignInWithText(),
                  //    _buildSocialBtnRow(),
                      _buildSignupBtn(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  _navigateRegistration() {
    NavigationRouter.switchToRegistration(context);
  }

  _navigateHomePage() {
    @Override
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.signinButton:
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
                    String URL = "https://hbutt877.pythonanywhere.com/signin";
                    JSONObject jsonBody = new JSONObject();
                    jsonBody.put("username", username.getText().toString().toLowerCase());
                    jsonBody.put("password", password.getText());
                    final String requestBody = jsonBody.toString();
                    StringRequest stringRequest = new StringRequest(Request.Method.POST, URL, new Response.Listener<String>() {
                        @Override
                        public void onResponse(String response) {
                            Log.i("VOLLEY", response);
                            if(response.equals("account login sccuessfully")){
                                Speak("Account logged in successfully");
                                Intent homeIntent = new Intent(SigninActivity.this,HomeActivity.class);
                                homeIntent.putExtra("username",username.getText().toString().toLowerCase());
                                homeIntent.putExtra("password",password.getText().toString());
                                startActivity(homeIntent);
                            }
                            else if(response.equals("account login failed")){
                                Speak("Wrong username or password");
                            }
                            else{
                                Speak("Error");
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
                Speak("sign in is clicked");
                break;
        }
    }
    NavigationRouter.switchToHomePage(context);
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
              Speak("Username is Empty");
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
