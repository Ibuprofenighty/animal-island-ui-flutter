import 'package:flutter/painting.dart';

const galleryPhotos = [
  'hillside-town.jpg',
  'lake-morning.jpg',
  'photo-01.jpg',
  'photo-02.jpg',
  'photo-03.jpg',
  'photo-04.jpg',
  'photo-05.jpg',
  'photo-06.jpg',
  'photo-07.jpg',
  'photo-08.jpg',
  'photo-09.jpg',
  'photo-10.jpg',
  'photo-11.jpg',
  'photo-12.jpg',
  'photo-13.jpg',
  'sunny-field.jpg',
];
AssetImage galleryPhoto(int index) =>
    AssetImage('assets/photos/${galleryPhotos[index % galleryPhotos.length]}');
