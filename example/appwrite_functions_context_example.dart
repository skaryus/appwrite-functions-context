import 'dart:async';

import 'package:appwrite_functions_context/appwrite_functions_context.dart';

Future<dynamic> main(final dynamic ctx) {
  return fMain(ctx: ctx, customFunc: customFunc);
}

Future<FunctionResult> customFunc(FContext ctx) async {
  // Your code goes here ...
  // ...
  // ...
  ctx.log("Your Log");
  ctx.error("Your Error");

  // Return call must be coming from [FContext].res.* method !
  return ctx.res.empty();
}
