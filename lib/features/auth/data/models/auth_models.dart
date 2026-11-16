class RegisterRequest {
    const RegisterRequest({
        required this.firstName,
        required this.lastName,
        required this.password,
        required this.dob,
        required this.gender,
        required this.email,
        required this.phone,
        required this.confirmPassword,
    });

    final String firstName,
            lastName,
            password,
            dob,
            gender,
            email,
            phone,
            confirmPassword;

    Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'password': password,
        'dob': dob,
        'gender': gender,
        'email': email,
        'phone': phone,
        'conf_password': confirmPassword,
    };
}

class LoginRequest {
    const LoginRequest({required this.username, required this.password});
    final String username, password;
    Map<String, dynamic> toJson() => {'username': username, 'password': password};
}

class AuthSession {
    const AuthSession({required this.accessToken, required this.refreshToken});
    final String accessToken, refreshToken;

    factory AuthSession.fromJson(dynamic body) {
        final map = body is Map<String, dynamic> ? body : <String, dynamic>{};
        final data = map['data'] is Map<String, dynamic>
                ? map['data'] as Map<String, dynamic>
                : map;
        return AuthSession(
            accessToken:
                    (data['accessToken'] ?? data['access_token'] ?? data['token'] ?? '')
                            as String,
            refreshToken:
                    (data['refreshToken'] ?? data['refresh_token'] ?? '') as String,
        );
    }
}
