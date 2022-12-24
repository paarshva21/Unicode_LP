import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:untitled/Models/Utils.dart';
import 'package:untitled/Screens/UserPage.dart';

class PhoneAuth extends StatefulWidget {
  const PhoneAuth({Key? key}) : super(key: key);

  @override
  State<PhoneAuth> createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  final formKey = GlobalKey<FormState>();

  String phoneNo = "";
  final TextEditingController phoneController = TextEditingController();
  String countryDial = "+91";
  final user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: SafeArea(
          child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/blacked.jpg"),
                      fit: BoxFit.cover,
                      opacity: 0.5)),
              child: Center(
                child: Scaffold(
                    backgroundColor: Colors.transparent,
                    body: GestureDetector(
                        onTap: () {
                          FocusScopeNode currentFocus = FocusScope.of(context);

                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                        },
                        child: SingleChildScrollView(
                            child: Center(
                          child: Column(children: [
                            SizedBox(
                              width: 20.0,
                              height: 30.0,
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 300.0),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(Icons.arrow_back_sharp),
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 230),
                              child: Text(
                                "Login via Phone Number.",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.all(20.0)),
                            Container(
                                padding:
                                    EdgeInsets.only(left: 35.0, right: 35.0),
                                child: IntlPhoneField(
                                  controller: phoneController,
                                  showCountryFlag: false,
                                  showDropdownIcon: true,
                                  initialCountryCode: 'IN',
                                  onCountryChanged: (country) {
                                    countryDial = "+" + country.dialCode;
                                  },
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(13),
                                      fillColor: Colors.white,
                                      filled: true,
                                      hintText: "   Phone No",
                                      hintStyle: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey),
                                      errorStyle: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(7.0),
                                          borderSide: BorderSide.none)),
                                )),
                            Padding(padding: EdgeInsets.all(20.0)),
                            Container(
                                width: 135.0,
                                height: 40.0,
                                color: Colors.green,
                                child: TextButton(
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      phoneNo = phoneController.text.trim();
                                      verifyPhone(
                                          PhoneNo: phoneNo,
                                          CountryCode: countryDial,
                                          context: context);
                                    }
                                  },
                                  child: Text(
                                    "Send OTP",
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                )),
                          ]),
                        )))),
              )),
        ));
  }
}

Future verifyPhone(
    {required String PhoneNo,
    required String CountryCode,
    required BuildContext context}) async {
  final TextEditingController codeController = TextEditingController();

  await FirebaseAuth.instance.verifyPhoneNumber(
    phoneNumber: CountryCode + PhoneNo,
    verificationCompleted: (PhoneAuthCredential credential) async {},
    verificationFailed: (FirebaseAuthException e) {
      if (e.code == 'invalid-phone-number') {
        print(e.toString());
        Utils.showSnackBar(e.toString());
      }
    },
    codeSent: (String verificationId, int? resendToken) async {
      showOTPDialog(
        codeController: codeController,
        context: context,
        confirmOTP: () async {
          Future<bool> checkIfDocExists() async {
            final user = FirebaseAuth.instance.currentUser;
            var doc = await FirebaseFirestore.instance
                .collection("Email Users")
                .doc(user?.uid)
                .get();
            try {
              return doc.exists;
            } catch (e) {
              print(e.toString());
              return false;
            }
          }

          PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: codeController.text.trim(),
          );
          final user = FirebaseAuth.instance.currentUser;
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            if (await checkIfDocExists() == false) {
              await FirebaseFirestore.instance
                  .collection('Email Users')
                  .doc(user?.uid)
                  .set({"Email": "No email", "Password": "No password"});
            }
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => UserPage()));
          } catch (e) {
            print(e.toString());
            Utils.showSnackBar(e.toString());
          }
        },
      );
    },
    codeAutoRetrievalTimeout: (String verificationId) {},
  );
}

void showOTPDialog({
  required BuildContext context,
  required TextEditingController codeController,
  required VoidCallback confirmOTP,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text("Enter OTP"),
      content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        TextFormField(
          keyboardType: TextInputType.number,
          controller: codeController,
          validator: (value) {
            if (value!.length < 7) {
              return "Enter valid OTP";
            }
          },
        )
      ]),
      actions: <Widget>[
        TextButton(
          child: const Text(
            'Confirm Code',
            style: TextStyle(color: Colors.black),
          ),
          onPressed: confirmOTP,
        )
      ],
    ),
  );
}
