class CloudAccount {
    const CloudAccount({
        required this.id,
        required this.provider,
        required this.email,
        required this.displayName,
        required this.status,
    });

    final String id;
    final String provider;
    final String email;
    final String displayName;
    final String status;

    bool get isActive => status == 'active';

    factory CloudAccount.fromJson(Map<String, dynamic> json) => CloudAccount(
        id: (json['_id'] ?? json['id'] ?? '') as String,
        provider: (json['provider'] ?? 'google') as String,
        email: (json['email'] ?? '') as String,
        displayName: (json['displayName'] ?? '') as String,
        status: (json['status'] ?? 'unknown') as String,
    );
}
