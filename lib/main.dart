import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

// MODEL
class User {
  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;

  final String street;
  final String suite;
  final String city;
  final String zipcode;
  final String lat;
  final String lng;

  final String companyName;
  final String catchPhrase;
  final String bs;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.street,
    required this.suite,
    required this.city,
    required this.zipcode,
    required this.lat,
    required this.lng,
    required this.companyName,
    required this.catchPhrase,
    required this.bs,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      website: json['website'],
      street: json['address']['street'],
      suite: json['address']['suite'],
      city: json['address']['city'],
      zipcode: json['address']['zipcode'],
      lat: json['address']['geo']['lat'],
      lng: json['address']['geo']['lng'],
      companyName: json['company']['name'],
      catchPhrase: json['company']['catchPhrase'],
      bs: json['company']['bs'],
    );
  }
}

// API SERVICE
class ApiService {
  static const String url = "https://jsonplaceholder.typicode.com/users";

  static Future<List<User>> fetchUsers() async {
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'flutter_application_1/1.0',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => User.fromJson(e)).toList();
      }

      if (response.statusCode == 403) {
        throw Exception(
          'Akses ditolak server (403). Cek jaringan device (VPN/proxy/firewall) atau ganti koneksi internet.',
        );
      }

      throw Exception("Gagal load data (status: ${response.statusCode})");
    } on TimeoutException {
      throw Exception("Request timeout. Koneksi terlalu lambat / tidak stabil");
    } on SocketException {
      throw Exception("Tidak ada koneksi internet");
    } on FormatException {
      throw Exception("Format response API tidak valid");
    } catch (e) {
      throw Exception("Error saat ambil data: $e");
    }
  }
}

// APP ROOT
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Users App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: const UserPage(),
    );
  }
}

// PAGE
class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late Future<List<User>> futureUsers;

  @override
  void initState() {
    super.initState();
    futureUsers = ApiService.fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Users"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFECEFF1), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<User>>(
          future: futureUsers,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Terjadi kesalahan:\n${snapshot.error}",
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Data kosong"));
            }

            final users = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.blueGrey.shade100),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.group, color: Colors.blueGrey),
                        const SizedBox(width: 8),
                        Text(
                          "Menampilkan ${users.length} users",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final user = users[index - 1];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shadowColor: Colors.blueGrey.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.blueGrey.shade600,
                              child: Text(
                                user.name[0],
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.username,
                                    style: TextStyle(
                                      color: Colors.blueGrey.shade400,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                user.city,
                                style: const TextStyle(
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(user.email)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(user.phone)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.language_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(user.website)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
