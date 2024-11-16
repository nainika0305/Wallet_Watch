import 'package:flutter/material.dart';
import 'package:wallet_watch/wrapper.dart';


//only when registering for the first time

class TermsAndConditions extends StatefulWidget {
  @override
  _TermsAndConditions createState() => _TermsAndConditions();
}

class _TermsAndConditions extends State<TermsAndConditions> {

  bool _isAccepted = false; // Track if terms are accepted

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Text('Please read and accept the terms n conditions'),
            SizedBox(height: 16),
            Expanded(
                child: SingleChildScrollView(
                child: Text('put the policy n all here'),
               ),
            ),
            Row(
              children: [
                Checkbox(
                  value: _isAccepted,
                  onChanged: (bool?value){
                  setState( () { //update ui 
                    _isAccepted = value ?? false;
                  });
                  },
                ),
                Expanded(child: GestureDetector(
                  onTap: (){
                    setState(() {
                      _isAccepted = !_isAccepted;
                    });
                  },
                  child: Text('I accept the terms'),
                ),
                )
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isAccepted
                ?() {
                Navigator.pushNamed(context, '/wrapper');
              }
              : null, //not allowed to press till accpet 
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
