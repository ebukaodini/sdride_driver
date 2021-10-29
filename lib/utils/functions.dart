import 'package:flutter/material.dart';

screen(BuildContext context) {
  return MediaQuery.of(context).copyWith().size;
}

Map getRouteArgs(BuildContext context) {
  final Map args = ModalRoute.of(context)!.settings.arguments as Map;
  return args;
}

String stripExceptions(errmsg) {
  print(errmsg);
  return errmsg.toString().replaceAll("Exception: ", "");
}
