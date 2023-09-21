// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `English`
  String get language {
    return Intl.message(
      'English',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Welcome To Chat & Live`
  String get welcome_landing {
    return Intl.message(
      'Welcome To Chat & Live',
      name: 'welcome_landing',
      desc: '',
      args: [],
    );
  }

  /// `Read our Privacy Policy. Tap "Agree and continue to accept the Terms of Services"`
  String get read_our_privacy {
    return Intl.message(
      'Read our Privacy Policy. Tap "Agree and continue to accept the Terms of Services"',
      name: 'read_our_privacy',
      desc: '',
      args: [],
    );
  }

  /// `AGREE AND CONTINUE`
  String get agree_continue {
    return Intl.message(
      'AGREE AND CONTINUE',
      name: 'agree_continue',
      desc: '',
      args: [],
    );
  }

  /// `CHATS`
  String get chat {
    return Intl.message(
      'CHATS',
      name: 'chat',
      desc: '',
      args: [],
    );
  }

  /// `STATUS`
  String get status {
    return Intl.message(
      'STATUS',
      name: 'status',
      desc: '',
      args: [],
    );
  }

  /// `CALLS`
  String get calls {
    return Intl.message(
      'CALLS',
      name: 'calls',
      desc: '',
      args: [],
    );
  }

  /// `Create Group`
  String get create_group {
    return Intl.message(
      'Create Group',
      name: 'create_group',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Enter your phone number`
  String get enter_phone_num {
    return Intl.message(
      'Enter your phone number',
      name: 'enter_phone_num',
      desc: '',
      args: [],
    );
  }

  /// `Chat&Live needs to verify your phone number.`
  String get login_heading {
    return Intl.message(
      'Chat&Live needs to verify your phone number.',
      name: 'login_heading',
      desc: '',
      args: [],
    );
  }

  /// `Pick Country`
  String get pick_country {
    return Intl.message(
      'Pick Country',
      name: 'pick_country',
      desc: '',
      args: [],
    );
  }

  /// `Phone number`
  String get phone_num {
    return Intl.message(
      'Phone number',
      name: 'phone_num',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `Fill out all the fields`
  String get login_snackbar_error {
    return Intl.message(
      'Fill out all the fields',
      name: 'login_snackbar_error',
      desc: '',
      args: [],
    );
  }

  /// `Verifying your number`
  String get verify_num {
    return Intl.message(
      'Verifying your number',
      name: 'verify_num',
      desc: '',
      args: [],
    );
  }

  /// `We have sent an SMS with a code.`
  String get sms_sent {
    return Intl.message(
      'We have sent an SMS with a code.',
      name: 'sms_sent',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Name`
  String get enter_name {
    return Intl.message(
      'Enter Your Name',
      name: 'enter_name',
      desc: '',
      args: [],
    );
  }

  /// `Enter Group Name`
  String get enter_group_name {
    return Intl.message(
      'Enter Group Name',
      name: 'enter_group_name',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Description`
  String get enter_description {
    return Intl.message(
      'Enter Your Description',
      name: 'enter_description',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Incoming Call`
  String get incoming_call {
    return Intl.message(
      'Incoming Call',
      name: 'incoming_call',
      desc: '',
      args: [],
    );
  }

  /// `Online`
  String get online {
    return Intl.message(
      'Online',
      name: 'online',
      desc: '',
      args: [],
    );
  }

  /// `Offline`
  String get offline {
    return Intl.message(
      'Offline',
      name: 'offline',
      desc: '',
      args: [],
    );
  }

  /// `Type a message...`
  String get chat_box_hint {
    return Intl.message(
      'Type a message...',
      name: 'chat_box_hint',
      desc: '',
      args: [],
    );
  }

  /// `Document`
  String get doc {
    return Intl.message(
      'Document',
      name: 'doc',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get cam {
    return Intl.message(
      'Camera',
      name: 'cam',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get gal {
    return Intl.message(
      'Gallery',
      name: 'gal',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get loc {
    return Intl.message(
      'Location',
      name: 'loc',
      desc: '',
      args: [],
    );
  }

  /// `Contacts`
  String get con {
    return Intl.message(
      'Contacts',
      name: 'con',
      desc: '',
      args: [],
    );
  }

  /// `Add a caption`
  String get add_caption {
    return Intl.message(
      'Add a caption',
      name: 'add_caption',
      desc: '',
      args: [],
    );
  }

  /// `Select Contact`
  String get select_contact {
    return Intl.message(
      'Select Contact',
      name: 'select_contact',
      desc: '',
      args: [],
    );
  }

  /// `Type a status...`
  String get status_hint {
    return Intl.message(
      'Type a status...',
      name: 'status_hint',
      desc: '',
      args: [],
    );
  }

  /// `Reply`
  String get reply {
    return Intl.message(
      'Reply',
      name: 'reply',
      desc: '',
      args: [],
    );
  }

  /// `Send 🌎🚀`
  String get share {
    return Intl.message(
      'Send 🌎🚀',
      name: 'share',
      desc: '',
      args: [],
    );
  }

  /// `Choose Your Locale Language`
  String get choose_lang {
    return Intl.message(
      'Choose Your Locale Language',
      name: 'choose_lang',
      desc: '',
      args: [],
    );
  }

  /// `Choose Your Favourite App Theme`
  String get choose_theme {
    return Intl.message(
      'Choose Your Favourite App Theme',
      name: 'choose_theme',
      desc: '',
      args: [],
    );
  }

  /// `Delete Account`
  String get delete_account {
    return Intl.message(
      'Delete Account',
      name: 'delete_account',
      desc: '',
      args: [],
    );
  }

  /// `App Language:`
  String get app_lang {
    return Intl.message(
      'App Language:',
      name: 'app_lang',
      desc: '',
      args: [],
    );
  }

  /// `Your Contacts`
  String get contacts {
    return Intl.message(
      'Your Contacts',
      name: 'contacts',
      desc: '',
      args: [],
    );
  }

  /// `Groups and Channels`
  String get groups {
    return Intl.message(
      'Groups and Channels',
      name: 'groups',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
