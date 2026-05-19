import 'dart:math';

String get fakeImage => 'https://cataas.com/cat/says/${Random().nextInt(99999999)}';

String userAvatarImage = 'https://cataas.com/cat/says/user';
String userCoverImage = 'https://cataas.com/cat/says/user';
String userCroppedImage =
    'https://s3-alpha-sig.figma.com/img/77c2/54e5/1989ea854d7fb27fab72561bea1861e9?Expires=1709510400&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=OQ89ZcUV8i7bityLO7vG5kEdpb9qHnEM6dE6J4zs8KqkrbYAvSbB6S8g8kKXhQ4ovDLg-JpJJKxh3mQtt3RHIWf2oLNx~qYg7yJdLpttq9VKH2hGHwWLJxPC4wUqWC4h8UNeqCuZXtZSfQKT0NP3cbRpaYqSfJtgyhOIE7AWJan26UzHaYsEINbIAP0R9mlLCFaf0gSp8uVcCOjUiyiEqZlU6UKpo4wQZNpO62Ftiq5d4qvGJQ6yOqT5GCEVxB4~HSOYauXL7dlRkoz5C0OhRhKNPw7x6-3BHr52jobxhNkWpX~Krm5sWzopT6NB~fCUz2Zc95nZ45oXC2JXYUkcrQ__';

Duration get randomDuration {
  const durations = [
    Duration(milliseconds: 750),
    Duration(milliseconds: 1000),
    Duration(milliseconds: 1250),
    Duration(milliseconds: 1500),
    Duration(milliseconds: 1750),
  ];
  return durations[Random().nextInt(durations.length)];
}
