import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_new_version/auth/auth_cubit.dart';
import 'package:test_new_version/auth/auth_repository.dart';
import 'package:test_new_version/auth/form_submission_status.dart';
import 'package:test_new_version/auth/login/login_bloc.dart';
import 'package:test_new_version/auth/login/login_event.dart';
import 'package:test_new_version/auth/login/login_state.dart';
import 'package:test_new_version/constants.dart';

class LoginView extends StatelessWidget {
  final _formkey = GlobalKey<FormState>();
  bool alarm1 = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: BlocProvider(
        create: (context) => LoginBloc(
          authRepo: context.read<AuthRepository>(),
          authCubit: context.read<AuthCubit>(),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _loginForm(size,context),

          ],
        ),
      ),
    );
  }

  Widget _loginForm(size,context){
    return BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          final formStatus = state.formStatus;
          if (formStatus is SubmissionFailed) {
            _showSnackBar(context, formStatus.exception.toString());
          }
        } ,
        child: Form(
          key: _formkey,
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
                            SizedBox(height: size.height * 0.17),
                            Image.asset('assets/images/smarty1.PNG',
                              height:280,
                              width: 280,),
                            SizedBox(height: size.height * 0.005),
                            _usernameField(),
                            SizedBox(height: size.height * 0.02),
                            _passwordField(),
                            SizedBox(height: size.height * 0.02),
                            _loginButton(size),
                            SizedBox(height: size.height * 0.053),
                            _showSignUpButton(context),
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
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state){
      return Stack(
        children: [
          Container(
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
              decoration: const InputDecoration(
                border: InputBorder.none,
                icon: Icon(Icons.person),
                hintText: 'ユーザー名',
                hintStyle: TextStyle(fontSize: 14.0),
              ),
              validator: (value) =>
              state.isValidUsername ? null : 'Username is too short',
              onChanged: (value) =>
                  context.read<LoginBloc>().add(LoginUsernameChanged(username: value),
                  ),
            ),
          ),
        ],
      );


    });
  }

  Widget _passwordField(){
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state){
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
              context.read<LoginBloc>().add(LoginPasswordChanged(password: value),
              ),
        ),
      );
    });
  }

  Widget _loginButton(size) {
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
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
              if(_formkey.currentState!.validate()){
                alarm1 = true;
                context.read<LoginBloc>().add(LoginSubmitted());
              }
            },
            child: const Text(
              'ログイン',
              style: TextStyle(fontSize: 14.0, color: Colors.white),
            ),
          ),
        ),
      );
    });
  }

  Widget _showSignUpButton(BuildContext context){
    return SafeArea(
        child: TextButton(
            onPressed: () => context.read<AuthCubit>().showSignUp(),
            child: const Text('アカウントはお持ちですか? 会員登録.',
              style: TextStyle(fontSize: 12.5,
                //fontWeight: FontWeight.bold,
                fontFamily: 'Cursive',)
              ,
            )));
  }

  void _showSnackBar(BuildContext context, String message){
   String message1 = message;
   if(message.contains('User not found in the system')){
     message1 = 'IDを確認してください。';
   }
   if(message.contains('Failed since user is not authorized')){
     message1 = 'パスワードを確認してください。';
   }
   if(message.contains('Unable to execute HTTP request: unable')){
     message1 = 'ネットワークを確認してください。';
   }

    final snackBar =  SnackBar(content: Text(message1));
    if(alarm1 == true){
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    alarm1=false;
    }
  }

}
