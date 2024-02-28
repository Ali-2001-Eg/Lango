// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/base/error_screen.dart';
import 'custom_indicator.dart';

class CustomStreamOrFutureWidget<T> extends ConsumerWidget {
  final StreamProvider<T>? stream;
  final FutureProvider<T>? future;
  final Widget Function(T data) builder;
  final Widget? loader;
  const CustomStreamOrFutureWidget({
    super.key,
    required this.stream,
    this.future,
    required this.builder,
    this.loader,
  }) : assert(stream != null || future != null);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(stream != null ? stream! : future!).when(
          data: builder,
          error: (err, stackTrace) {
            return ErrorScreen(error: err.toString());
          },
          loading: () {
            return loader == null
                ? const Center(child: CustomIndicator())
                : loader!;
          },
        );
  }
}
