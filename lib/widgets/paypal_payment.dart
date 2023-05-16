import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';

void paypalPaymentDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text(
        'Upgrade to Pro!',
        textAlign: TextAlign.center,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                // fixedSize: Size(
                //   MediaQuery.of(context).size.width * .8,
                //   MediaQuery.of(context).size.height * .07,
                // ),
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => UsePaypal(
                        sandboxMode: true,
                        clientId:
                            "AW1TdvpSGbIM5iP4HJNI5TyTmwpY9Gv9dYw8_8yW5lYIbCqf326vrkrp0ce9TAqjEGMHiV3OqJM_aRT0",
                        secretKey:
                            "EHHtTDjnmTZATYBPiGzZC_AZUfMpMAzj2VZUeqlFUrRJA_C0pQNCxDccB5qoRQSEdcOnnKQhycuOWdP9",
                        returnURL: "https://samplesite.com/return",
                        cancelURL: "https://samplesite.com/cancel",
                        transactions: const [
                          {
                            "amount": {
                              "total": '4.99',
                              "currency": "USD",
                              "details": {
                                "subtotal": '4.99',
                                "shipping": '0',
                                "shipping_discount": 0
                              }
                            },
                            "description":
                                "Payment for pro account subscription.",
                            // "payment_options": {
                            //   "allowed_payment_method":
                            //       "INSTANT_FUNDING_SOURCE"
                            // },
                            // "item_list": {
                            //   "items": [
                            //     {
                            //       "name": "A demo product",
                            //       "quantity": 1,
                            //       "price": '10.12',
                            //       "currency": "USD"
                            //     }
                            //   ],

                            //   // shipping address is not required though
                            //   "shipping_address": {
                            //     "recipient_name": "Jane Foster",
                            //     "line1": "Travis County",
                            //     "line2": "",
                            //     "city": "Austin",
                            //     "country_code": "US",
                            //     "postal_code": "73301",
                            //     "phone": "+00000000",
                            //     "state": "Texas"
                            //   },
                            // }
                          }
                        ],
                        note: "Contact us for any questions on your order.",
                        onSuccess: (Map params) async {
                          debugPrint("onSuccess: $params");
                        },
                        onError: (error) {
                          debugPrint("onError: $error");
                        },
                        onCancel: (params) {
                          debugPrint('cancelled: $params');
                        }),
                  ),
                );
              },
              icon: const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Icon(Icons.paypal_rounded),
              ),
              label: const Padding(
                padding: EdgeInsets.only(
                  top: 15,
                  bottom: 15,
                  right: 15,
                  left: 10,
                ),
                child: Text('Pay with Paypal'),
              ),
            ),
          ),
        )
      ],
    ),
  );
}
