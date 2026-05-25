// lib/services/account_services.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:reportaya/configs/generic_response.dart';

import '../models/account.dart';

class AccountService {
  Future<GenericResponse<Account>> login(Account account) async {
    try {
      // read json as string
      String jsonString = await rootBundle.loadString(
        'lib/assets/jsons/accounts.json',
      );
      // string to json
      final List<dynamic> jsonList = json.decode(jsonString);
      // json to object
      final List<Account> accounts = jsonList
          .map((json) => Account.fromJson(json))
          .toList();

      // search account
      for (Account a in accounts) {
        if (account.username == a.username &&
            account.passwordHash == a.passwordHash) {
          return GenericResponse(
            success: true,
            data: a,
            message: 'Login exitoso',
            error: null,
          );
        }
      }
      // account not found
      return GenericResponse(
        success: false,
        data: null,
        message: 'Usuario y/o contraseña no válidos',
        error: null,
      );
    } catch (e, stackTrace) {
      //print('Error: $e'); // 'Error ' + e;
      //print('Stack Trace: $stackTrace');
      return GenericResponse(
        success: false,
        data: null,
        message: 'Ocurrió un error no esperado en el login',
        error: stackTrace.toString(),
      );
    }
  }
}
