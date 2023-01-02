import 'dart:convert';
import 'dart:developer';

import 'package:flyket/model/apis/airport.dart';

import 'package:flyket/model/apis/summary.dart';

import 'package:flyket/model/apis/transaction_history.dart';
import 'package:flyket/model/apis/notification.dart';

import 'package:flyket/model/apis/user.dart';
import 'package:flyket/model/schedule/schedule.dart';
import 'package:flyket/model/transactions/transanction.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class WebServices {
  static const String BASE_URL = "https://flytick-dev.up.railway.app/api";
  static const String token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwibmFtZSI6IlNla2FyIE1LIiwiZW1haWwiOiJzZWthcm1hZHVrdXN1bWF3YXJkYW5pQGdtYWlsLmNvbSIsInBhc3N3b3JkIjoiJDJiJDEwJEhNemhkbDNYNTZLZVY4d1Zaa2JNd3VFU1hqMXlCYWhqSk8zVFRCSW5idjBDYTY2QXVNTmJPIiwiYXZhdGFyX2lkIjoxLCJyb2xlIjoic3VwZXJhZG1pbiIsImJhbGFuY2UiOjEwMDAwMDAwLCJiaW9kYXRhX2lkIjoxLCJsb2dpbl90eXBlIjoiYmFzaWMiLCJpYXQiOjE2NzA4MzAwMTF9.vzjAE1wpAIs8EHiALns_T3yyX9wX2eKczu7ab-bsa5k";

  Future<List<Airport>> fetchAirportList() async {
    String endpoint = "/airport";
    var url = Uri.parse(BASE_URL + endpoint);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final Iterable json = body["data"];
      return json.map((e) => Airport.fromJson(e)).toList();
    } else {
      throw Exception("Unable to perform request");
    }
  }

  Future<List<TransactionHistory>> getAllTransactions() async {
    String endpoint = "/transaction";

    final response = await http
        .get(Uri.parse(BASE_URL + endpoint), headers: {'Authorization': token});
    if (response.statusCode == 200) {
      var jsonObject = json.decode(response.body);
      List<dynamic> listTransaction =
          (jsonObject as Map<String, dynamic>)['data'];

      List<TransactionHistory> transactions = [];
      for (int i = 0; i < listTransaction.length; i++) {
        transactions.add(TransactionHistory.fromJson(listTransaction[i]));
      }

      return transactions;
    } else {
      throw response.statusCode;
    }
  }

  Future<List<Notification>> getUserNotifications() async {
    String endpoint = "/notification";

    final response = await http
        .get(Uri.parse(BASE_URL + endpoint), headers: {'Authorization': token});
    if (response.statusCode == 200) {
      var jsonObject = json.decode(response.body);
      List<dynamic> listNotification =
          (jsonObject as Map<String, dynamic>)['data'];

      List<Notification> notifications = [];
      for (int i = 0; i < listNotification.length; i++) {
        notifications.add(Notification.fromJson(listNotification[i]));
      }

      return notifications;
    } else {
      throw response.statusCode;
    }
  }

  Future<bool> readAllNotifications() async {
    String endpoint = "/notification/read-all";

    final response = await http
        .put(Uri.parse(BASE_URL + endpoint), headers: {'Authorization': token});
    if (response.statusCode == 200) {
      var jsonObject = json.decode(response.body);
      var isRead = (jsonObject as Map<String, dynamic>)['data'][0];

      return (isRead == 0 ? false : true);
    } else {
      throw response.statusCode;
    }
  }

  Future<User?> login(String email, String password) async {
    var url = Uri.parse("${BASE_URL}/auth/login");
    Response response = await http.post(
      url,
      body: jsonEncode(
        <String, String>{'email': email, 'password': password},
      ),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      log("response status: " + response.body);
      final body = jsonDecode(response.body);
      return User.fromJson(body["data"]);
    } else {
      return null;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    var url = Uri.parse("${BASE_URL}/auth/register");
    Response response = await http.post(
      url,
      body: jsonEncode(
        <String, String>{"name": name, "email": email, "password": password},
      ),
      headers: {'Content-Type': 'application/json'},
    );

    log("response.statusCode: ${response.statusCode}");

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<Schedule>> fetchScheduleList(
      String departureTime, int from_airport, int to_airport, int adult) async {
    final url = Uri.parse(
        "$BASE_URL/schedule?departure_time=$departureTime&from_airport=${from_airport.toString()}&to_airport=${to_airport.toString()}&adult=${adult.toString()}&child=0");

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwibmFtZSI6IlNla2FyIE1LIiwiZW1haWwiOiJzZWthcm1hZHVrdXN1bWF3YXJkYW5pQGdtYWlsLmNvbSIsInBhc3N3b3JkIjoiJDJiJDEwJEhNemhkbDNYNTZLZVY4d1Zaa2JNd3VFU1hqMXlCYWhqSk8zVFRCSW5idjBDYTY2QXVNTmJPIiwiYXZhdGFyX2lkIjoxLCJyb2xlIjoic3VwZXJhZG1pbiIsImJhbGFuY2UiOjEwMDAwMDAwLCJiaW9kYXRhX2lkIjoxLCJsb2dpbl90eXBlIjoiYmFzaWMiLCJpYXQiOjE2NzA4MzAwMTF9.vzjAE1wpAIs8EHiALns_T3yyX9wX2eKczu7ab-bsa5k",
      },
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final Iterable json = body["data"]["schedules"];
      return json.map((e) => Schedule.fromJson(e)).toList();
    } else {
      throw Exception("Unable to fetch schedule.");
    }
  }

  Future<bool> createTransaction(Transaction transaction) async {
    final url = Uri.parse("$BASE_URL/transaction");
    log(url.toString());

    try {
      final Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MywibmFtZSI6Ik1hZHUgS3VzdW1hd2FyZGFuaSIsImVtYWlsIjoic2VrYXJtYWR1QHVwaS5lZHUiLCJwYXNzd29yZCI6IiQyYiQxMCRBZkFOaFdWVDdiZ25YSHJFbTBvT1dlS3RQQjBILy9aLk1UdHh3M1lqektYOFBNOVlYZTRKSyIsImF2YXRhcl9pZCI6MSwicm9sZSI6InVzZXIiLCJiYWxhbmNlIjoxMDAwMDAwMCwiYmlvZGF0YV9pZCI6MywibG9naW5fdHlwZSI6ImJhc2ljIiwiaWF0IjoxNjcxNDQ1NzM4fQ.iFwbPUifSdOPR9GLKGvreEhcY4fViOHXMMV2dhEfpHM",
        },
        body: jsonEncode(<String, dynamic>{
          "user_id": transaction.userId,
          "schedule_id": transaction.scheduleId,
          "adult": transaction.adult,
          "child": transaction.child,
          "roundtrip": false,
          "biodataList": [
            {
              "body": {
                "email": "sekarmadukusumawardani@gmail.com",
                "name": "Sekar Testing Biodata 1",
                "nik": "1234567887654321",
                "birth_place": "Banjarnegara",
                "birth_date": "2002-07-03",
                "telp": "081234567890",
                "nationality": 1,
                "no_passport": "A9601796",
                "issue_date": "2014-11-17",
                "expire_date": "2019-11-17"
              }
            }
          ]
          // "biodataList": [
          //   {
          //     "body": {
          //       "name": "Sekar Testing Biodata 1",
          //       "nik": "1234567887654321",
          //       "telp": "081234567890",
          //     }
          //   }
          // ]
        }),
      );
      log(response.statusCode.toString());
      if (response.statusCode == 201) {
        final body = jsonDecode(response.body);
        return true;
      } else {
        // throw Exception("Unable to fetch schedule.");
        return false;
      }
    } catch (e) {
      log(e.toString());
      throw Exception("Fail");
    }

    // final Response response = await http.post(
    //   url,
    //   headers: {
    //     'Content-Type': 'application/json',
    //     'Authorization':
    //         "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MywibmFtZSI6Ik1hZHUgS3VzdW1hd2FyZGFuaSIsImVtYWlsIjoic2VrYXJtYWR1QHVwaS5lZHUiLCJwYXNzd29yZCI6IiQyYiQxMCRBZkFOaFdWVDdiZ25YSHJFbTBvT1dlS3RQQjBILy9aLk1UdHh3M1lqektYOFBNOVlYZTRKSyIsImF2YXRhcl9pZCI6MSwicm9sZSI6InVzZXIiLCJiYWxhbmNlIjoxMDAwMDAwMCwiYmlvZGF0YV9pZCI6MywibG9naW5fdHlwZSI6ImJhc2ljIiwiaWF0IjoxNjcxNDQ1NzM4fQ.iFwbPUifSdOPR9GLKGvreEhcY4fViOHXMMV2dhEfpHM",
    //   },
    //   body: jsonEncode(transaction),
    // );

    // log(response.statusCode.toString());
    // if (response.statusCode == 201) {
    //   final body = jsonDecode(response.body);
    //   return true;
    // } else {
    //   throw Exception("Unable to fetch schedule.");
    //   return false;
    // }
  }
}
