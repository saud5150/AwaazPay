import 'package:flutter/material.dart';
import 'package:awaazpay_v1/send_money_flow/select_account_page.dart';
import 'package:awaazpay_v1/widgets/bank_card.dart';
import 'package:awaazpay_v1/utilities/navigation_router.dart';
//import 'package:awaazpay_v1/main.dart';
import 'package:awaazpay_v1/history/history_page.dart';
import 'package:awaazpay_v1/profile/profile_page.dart';
import 'package:awaazpay_v1/settings/settings_page.dart';
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
class HomePage extends StatefulWidget {
  public final String TAG = "Activity_DroidSpeech";
  boolean isError = false;
  private DroidSpeech droidSpeech;
  private Button start,stop,sendButton;
  EditText username,amount,currentEditText;
  TextToSpeech t1;
  boolean isPaused = false;
  boolean isChecked;

  @Override
  protected void onCreate(Bundle savedInstanceState)
  {
      super.onCreate(savedInstanceState);

      // Setting the layout;[.
      setContentView(R.layout.activity_send_money);
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
      amount = findViewById(R.id.amountSendMoney);
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

  @override
  HomePageState createState() => HomePageState();

}
class HomePageState extends State<HomePage> {
  @Override
  public void onClick(View view) {
      switch (view.getId()) {
          case R.id.sendButtonSendMoney:
              if(username.getText().toString().equals("") ){
                  Speak("Username cannot be empty");
                  break;
              }
              if(amount.getText().toString().equals("")){
                  Speak("amount cannot be empty");
                  break;
              }
              if(username.getText().toString().equals(HomeActivity.username)){
                  Speak("cannot send money to yourself");
                  break;
              }
              try {
                  RequestQueue requestQueue = Volley.newRequestQueue(this);
                  String URL = "https://hbutt877.pythonanywhere.com/sendmoney";
                  JSONObject jsonBody = new JSONObject();
                  jsonBody.put("fromusername", HomeActivity.username);
                  jsonBody.put("frompassword", HomeActivity.password);
                  jsonBody.put("tousername", username.getText().toString().toLowerCase());
                  jsonBody.put("amount", amount.getText().toString());
                  final String requestBody = jsonBody.toString();
                  StringRequest stringRequest = new StringRequest(Request.Method.POST, URL, new Response.Listener<String>() {
                      @Override
                      public void onResponse(String response) {
                          Log.i("VOLLEY", response);
                          if(response.equals("success")){
                              Speak("money sent successfully");
                              finish();
                          }
                          else if(response.equals("incorrect amount")){
                              Speak("incorrect amount");
                          }
                          else if(response.equals("low balance")){
                              Speak("low balance");
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
      if(currentEditText==amount) {
          finalSpeechResult = finalSpeechResult.replaceAll("[^0-9]","");
      }
      else {
          finalSpeechResult = finalSpeechResult.replaceAll("[ ,]", "");
      }
      finalSpeechResult = finalSpeechResult.toLowerCase();
      if(finalSpeechResult.contains("back")){
          Speak("back button is clicked");
          onBackPressed();
          return;
      }
      else if(finalSpeechResult.contains("exit")){
          Speak("Good bye");
          this.finishAffinity();
          return;
      }
      if(finalSpeechResult.contains("username")){
          currentEditText = username;
          username.requestFocus();
          Speak("username is selected");
          return;
      }
      else if(finalSpeechResult.contains("amount")){
          currentEditText = amount;
          amount.requestFocus();
          Speak("amount is selected");
          return;
      }
      if (currentEditText == null) {
          Speak("Please Select Username or amount");
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
              Speak("Username is Empty");
          }
          else{
              s = s.substring(0, s.length() - 1);
              currentEditText.setText(s);
          }
      }
      else if(finalSpeechResult.equals("deleteall") || finalSpeechResult.equals("removeall") || finalSpeechResult.equals("backspaceall")){
          currentEditText.setText("");
          Speak("Username is Empty");
      }
      else if(finalSpeechResult.contains("speak")) {
          if (currentEditText.getText().length()>0){
              Speak("You have typed username, " + getSpeakable(username));
          }
          else{
              Speak("username is empty");
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
  int _curIndex = 0;
  final List<BankCardModel> cards = [
    BankCardModel('images/bg_red_card.png', 'Hamza Abbasi',
        '4221 5168 7464 2283', '08/20', 10000000),
    BankCardModel('images/bg_blue_circle_card.png', 'Hamza Abbasi',
        '4221 5168 7464 2283', '08/20', 1500000),
    BankCardModel('images/bg_purple_card.png', 'Hamza Abbasi',
        '4221 5168 7464 2283', '08/20', 100250),
    BankCardModel('images/bg_blue_card.png', 'Hamza Abbasi',
        '4221 5168 7464 2283', '08/20', 1000),
  ];

  double screenWidth = 0.0;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    // TODO: implement build

    Widget _getWidget() {
    switch (_curIndex) {
    case 0:
    return Container(
    color: Colors.red,
    child: HomePage(),
    );
    break;
    case 1:
    return Container(
    child: HistoryPage(),
    );
    break;
    case 2:
    return Container(
    child: ProfilePage(),
    );
    break;
    default:
    return Container(
    child: SettingsPage(),
    );
    break;
    }
    }
    body: new Center(
    child: _getWidget(),
    );



    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _curIndex,
//          iconSize: 22.0,
            onTap: (Index) {
              _curIndex = Index;
              setState(() { });
            },
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(_curIndex == 0 ? 'images/ico_home_selected.png' : 'images/ico_home.png'),
                title: Text(
                  'Home',
                  style: TextStyle(
                      color: Colors.black
                  ),
                ),
              ),
              BottomNavigationBarItem(
                icon: Image.asset(_curIndex == 1 ? 'images/ico_history_selected.png' : 'images/ico_history.png'),
                title: Text(
                  'History',
                  style: TextStyle(
                      color: Colors.black
                  ),
                ),
              ),
              BottomNavigationBarItem(
                icon: Image.asset(_curIndex == 2 ? 'images/ico_profile_selected.png' : 'images/ico_profile.png'),
                title: Text(
                  'Profile',
                  style: TextStyle(
                      color: Colors.black
                  ),
                ),
              ),
              BottomNavigationBarItem(
                icon: Image.asset(_curIndex == 3 ? 'images/ico_settings_selected.png' : 'images/ico_settings.png'),
                title: Text(
                  'Settings',
                  style: TextStyle(
                      color: Colors.black
                  ),
                ),
              ),
            ]),
      backgroundColor: Color(0xFFF4F4F4),
      body: ListView.builder(
          itemCount: 4,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return _userInfoWidget();
            } else if (index == 1) {
              return _userBankCardsWidget();
            } else if (index == 2) {
              return _sendMoneySectionWidget();
            } else {
              return _utilitesSectionWidget();
            }
          }),
    );
  }

  Widget _userInfoWidget() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    child: Text('T'),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      'Hamza Abbasi',
                      style: TextStyle(
                          fontFamily: 'Poppins', fontWeight: FontWeight.w700),
                    ),
                  )
                ],
              )),
          Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Icon(Icons.notifications_none,
                    size: 30.0,),
                ),
                new Positioned(  // draw a red marble
                  top: 3.0,
                  left: 3.0,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(0xFFE95482),
                        borderRadius: BorderRadius.circular(8.0)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                        '02',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.0,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                    ),
                  ),
                )
              ]
          ),
        ],
      ),
    );
  }

  Widget _userBankCardsWidget() {
    return Container(
      margin: EdgeInsets.only(top: 20.0),
//      height: 400.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
              child: Text('My Bank Accounts')),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            height: 166.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (BuildContext context, int index) {
                return _getBankCard(index);
              },
            ),
          ),
          Container(
            height: 80.0,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTapUp: (tapDetail) {
                      Navigator.push(context,
                          SelectAccountPageRoute());
                    },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Image.asset('images/ico_send_money.png'),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'Send\nmoney',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Image.asset('images/ico_receive_money.png'),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('Receive\nmoney',
                              style: TextStyle(fontWeight: FontWeight.w700),),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _sendMoneySectionWidget() {
    var smallItemPadding = EdgeInsets.only(
        left: 12.0, right: 12.0, top: 12.0);
    if (screenWidth <= 320) {
      smallItemPadding = EdgeInsets.only(
          left: 10.0, right: 10.0, top: 12.0);
    }
    return Container(
//      color: Colors.yellow,
      margin: EdgeInsets.all(16.0),
//      height: 200.0,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Send money to',
                    style:
                    TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              GestureDetector(
                onTapUp: null,
                child: Text('View all'),
              )
            ],
          ),
          Container(
            height: 100.0,
            child: Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: smallItemPadding,
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          'images/ico_add_new.png',
                          height: 40.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Add new'),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: smallItemPadding,
                    child: Column(
                      children: <Widget>[
                        CircleAvatar(
                          child: Text('T'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Salina'),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: smallItemPadding,
                    child: Column(
                      children: <Widget>[
                        CircleAvatar(
                          child: Text('T'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Emily'),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: smallItemPadding,
                    child: Column(
                      children: <Widget>[
                        CircleAvatar(
                          child: Text('T'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Nichole'),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _utilitesSectionWidget() {
    var smallItemPadding = EdgeInsets.only(
        left: 12.0, right: 12.0, top: 12.0);
    if (screenWidth <= 320) {
      smallItemPadding = EdgeInsets.only(
          left: 10.0, right: 10.0, top: 12.0);
    }
    return Container(
//      color: Colors.yellow,
      margin: EdgeInsets.all(16.0),
//      height: 200.0,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Utilities',
                    style:
                    TextStyle(fontSize: 14.0, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 80.0,
            child: Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: smallItemPadding,
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          'images/ico_pay_phone.png',
                          height: 26.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child:
                          Text('Mobile', style: TextStyle(fontSize: 12.0)),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: smallItemPadding,
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          'images/ico_pay_elect.png',
                          height: 26.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Electricity',
                            style: TextStyle(fontSize: 12.0),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: smallItemPadding,
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          'images/ico_pay_broad.png',
                          height: 26.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Broadband',
                              style: TextStyle(fontSize: 12.0)),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: smallItemPadding,
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          'images/ico_pay_gas.png',
                          height: 26.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Gas', style: TextStyle(fontSize: 12.0)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _getBankCard(int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BankCard(card: cards[index]),
    );
  }
}
