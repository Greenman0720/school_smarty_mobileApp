import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_new_version/auth/auth_cubit.dart';
import 'package:test_new_version/auth/auth_repository.dart';
import 'package:test_new_version/auth/form_submission_status.dart';
import 'package:test_new_version/auth/sign_up/sign_up_bloc.dart';
import 'package:test_new_version/auth/sign_up/sign_up_event.dart';
import 'package:test_new_version/auth/sign_up/sign_up_state.dart';
import 'package:test_new_version/constants.dart';


class SignUpView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  bool alarm1 = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: BlocProvider(
          create: (context) => SignUpBloc(
            authRepo: context.read<AuthRepository>(),
            authCubit: context.read<AuthCubit>(),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              _signUpForm(size,context),

            ],
          )

      ),
    );
  }

  Widget _signUpForm(size,context){
    return BlocListener<SignUpBloc, SignUpState>(
        listener: (context, state) {
          final formStatus = state.formStatus;
          if (formStatus is SubmissionFailed) {
            _showSnackBar(context, formStatus.exception.toString());
          }
        },
        child: Form(
          key: _formKey,
          child: Center(
            child: Container(
              decoration: const BoxDecoration(
                color: loginLightBlue,
              ),
              child: Row(children: [
                Expanded(child: Container(),flex: 12,),
                Expanded(child: SingleChildScrollView(
                  child: Stack(
                      children: [
                  Container(
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.48),
                      _usernameField(),
                      SizedBox(height: size.height * 0.02),
                      _emailField(),
                      SizedBox(height: size.height * 0.02),
                      _passwordField(),
                      SizedBox(height: size.height * 0.02),
                      _signUpbutton(size),
                      SizedBox(height: size.height * 0.053),
                      _showSignupButton(context),
                    ],
                  ),
                  ),
                      ],
                  ),
                ),flex: 86,),
                Expanded(child: Container(),flex: 12,),
              ],
              ),
            ),
          ),
        ));
  }

  Widget _usernameField(){
    return BlocBuilder<SignUpBloc, SignUpState>(
        builder: (context, state){
          return Container(
            height: 50,
            padding : const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black54,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(29),
            ),
            child: TextFormField(
              decoration:
              const InputDecoration(
                border: InputBorder.none,
                icon: Icon(Icons.person),
                hintText: 'ユーザー名',
                hintStyle: TextStyle(fontSize: 14.0),
              ),
              validator: (value) =>
              state.isValidUsername ? null : 'Username is too short',
              onChanged: (value) =>
                  context.read<SignUpBloc>().add(
                    SignUpUsernameChanged(username: value),
                  ),
            ),
          );
        });
  }

  Widget _emailField(){
    return BlocBuilder<SignUpBloc, SignUpState>(
        builder: (context, state){
          return Container(
            height: 50,
            padding : const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black54,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(29),
            ),
            child: TextFormField(
              decoration:
              const InputDecoration(
                border: InputBorder.none,
                icon: Icon(Icons.email),
                hintText: 'メール',
                hintStyle: TextStyle(fontSize: 14.0),
              ),
              validator: (value) =>
              state.isValidUsername ? null : 'Invalid email',
              onChanged: (value) =>
                  context.read<SignUpBloc>().add(
                    SignUpEmailChanged(email: value),
                  ),
            ),
          );
        });
  }


  Widget _passwordField(){
    return BlocBuilder<SignUpBloc, SignUpState>(
        builder: (context, state){
          return Container(
            height: 50,
            padding : const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black54,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(29),
            ),
            child: TextFormField(
              obscureText: true,
              decoration:
              const InputDecoration(
                border: InputBorder.none,
                icon: Icon(Icons.lock),
                hintText: 'パスワード',
                hintStyle: TextStyle(fontSize: 14.0),
              ),
              validator: (value) =>
              state.isValidPassword ? null : 'Password is too short',
              onChanged: (value) =>
                  context.read<SignUpBloc>().add(
                    SignUpPasswordChanged(password: value),
                  ),
            ),
          );
        });
  }



  Widget _signUpbutton(size){
    return BlocBuilder<SignUpBloc, SignUpState>(
        builder: (context, state) {
          return state.formStatus is FormSubmitting
              ? const CircularProgressIndicator()
              : SizedBox(
            width: double.infinity,
            height: size.height * 0.065,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(29),
              child: FlatButton(
                color: loginDarkBlue,
                onPressed: () {
                  if(_formKey.currentState!.validate()){
                    alarm1 = true;
                    context.read<SignUpBloc>().add(SignUpSubmitted());
                  }
                },
                child: const Text(
                  '新規会員登録',
                  style: TextStyle(fontSize: 14.0,color: Colors.white),
                ),
              ),
            ),
          );
        });
  }


  Widget _showSignupButton(BuildContext context){
    return SafeArea(
        child: TextButton(
          onPressed: () => context.read<AuthCubit>().showLogin(),
          child: const Text('すでにアカウントをお持ちですか? ログイン.',
              style: TextStyle(fontSize: 12.5,
                //fontWeight: FontWeight.bold,
                fontFamily: 'Cursive',)),

        ));
  }


  void _showSnackBar(BuildContext context, String message){
    String message1 = message;
    if(message.contains('One or more parameters are incorrect')){
      message1 = '入力情報を確認してください。';
    }
    if(message.contains('Unable to execute HTTP request: unable')){
      message1 = 'ネットワークを確認してください。';
    }

    final snackBar = SnackBar(content: Text(message1));
    if(alarm1 == true){
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      alarm1=false;
    }
  }

}
