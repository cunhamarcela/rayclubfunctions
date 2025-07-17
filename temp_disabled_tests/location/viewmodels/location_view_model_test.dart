// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/foundation.dart';

// Project imports:
class MockLocationRepository extends Mock implements LocationRepository {}
class MockLocationService extends Mock implements LocationService {}

void main() {
  late LocationViewModel viewModel;
  late MockLocationRepository mockRepository;
  late MockLocationService mockService;

  setUp(() {
    mockRepository = MockLocationRepository();
    mockService = MockLocationService();
    
    viewModel = LocationViewModel(
      repository: mockRepository,
      locationService: mockService,
    );
  });

  // group('LocationViewModel', () {
    // test('initial state is correct', () {
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.locations, isEmpty);
      expect(viewModel.state.currentLocation, isNull);
      expect(viewModel.state.errorMessage, isNull);
    });

    // group('loadNearbyLocations', () {
      // test('loads nearby locations successfully', () async {
        // Arrange
        final currentLocation = UserLocation(
          latitude: 40.7128,
          longitude: -74.0060,
        );
        
        final nearbyLocations = [
          Location(
            id: 'location-1',
            name: 'Ray Club - Centro',
            address: 'Rua Central, 123',
            latitude: 40.7130,
            longitude: -74.0062,
            phoneNumber: '(11) 1234-5678',
            email: 'centro@rayclub.com',
            openingHours: '06:00 - 22:00',
            amenities: ['Parking', 'Showers', 'Lockers'],
            distance: 0.3,
          ),
          Location(
            id: 'location-2',
            name: 'Ray Club - Norte',
            address: 'Av. Norte, 456',
            latitude: 40.7150,
            longitude: -74.0080,
            phoneNumber: '(11) 5678-1234',
            email: 'norte@rayclub.com',
            openingHours: '06:00 - 22:00',
            amenities: ['Parking', 'Showers', 'Pool'],
            distance: 1.2,
          ),
        ];
        
        when(() => mockService.getCurrentLocation())
            .thenAnswer((_) async => currentLocation);
            
        when(() => mockRepository.getNearbyLocations(
          latitude: 40.7128,
          longitude: -74.0060,
          radius: 5.0,
        )).thenAnswer((_) async => nearbyLocations);
        
        // Act
        await viewModel.loadNearbyLocations();
        
        // Assert
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.locations.length, 2);
        expect(viewModel.state.locations[0].id, 'location-1');
        expect(viewModel.state.locations[1].id, 'location-2');
        expect(viewModel.state.currentLocation, isNotNull);
        expect(viewModel.state.errorMessage, isNull);
        
        verify(() => mockService.getCurrentLocation()).called(1);
        verify(() => mockRepository.getNearbyLocations(
          latitude: 40.7128,
          longitude: -74.0060,
          radius: 5.0,
        )).called(1);
      });
      
      // test('handles error when location permission is denied', () async {
        // Arrange
        when(() => mockService.getCurrentLocation())
            .thenThrow(Exception('Permissão de localização negada'));
        
        // Act
        await viewModel.loadNearbyLocations();
        
        // Assert
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.locations, isEmpty);
        expect(viewModel.state.currentLocation, isNull);
        expect(viewModel.state.errorMessage, contains('Permissão de localização negada'));
        
        verify(() => mockService.getCurrentLocation()).called(1);
        verifyNever(() => mockRepository.getNearbyLocations(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          radius: any(named: 'radius'),
        ));
      });
    });
    
    // group('getLocationDetails', () {
      // test('gets location details successfully', () async {
        // Arrange
        final locationId = 'location-1';
        final location = Location(
          id: locationId,
          name: 'Ray Club - Centro',
          address: 'Rua Central, 123',
          latitude: 40.7130,
          longitude: -74.0062,
          phoneNumber: '(11) 1234-5678',
          email: 'centro@rayclub.com',
          openingHours: '06:00 - 22:00',
          amenities: ['Parking', 'Showers', 'Lockers'],
          distance: 0.3,
        );
        
        when(() => mockRepository.getLocationById(locationId))
            .thenAnswer((_) async => location);
        
        // Act
        final result = await viewModel.getLocationDetails(locationId);
        
        // Assert
        expect(result, isNotNull);
        expect(result.id, locationId);
        expect(viewModel.state.selectedLocation, isNotNull);
        expect(viewModel.state.selectedLocation?.id, locationId);
        
        verify(() => mockRepository.getLocationById(locationId)).called(1);
      });
      
      // test('handles error when getting location details fails', () async {
        // Arrange
        final locationId = 'non-existent-id';
        
        when(() => mockRepository.getLocationById(locationId))
            .thenThrow(Exception('Localização não encontrada'));
        
        // Act & Assert
        expect(() => viewModel.getLocationDetails(locationId), throwsException);
        
        verify(() => mockRepository.getLocationById(locationId)).called(1);
      });
    });
    
    // group('filterLocationsByAmenity', () {
      // test('filters locations by amenity', () async {
        // Arrange
        final locations = [
          Location(
            id: 'location-1',
            name: 'Ray Club - Centro',
            address: 'Rua Central, 123',
            latitude: 40.7130,
            longitude: -74.0062,
            phoneNumber: '(11) 1234-5678',
            email: 'centro@rayclub.com',
            openingHours: '06:00 - 22:00',
            amenities: ['Parking', 'Showers', 'Lockers'],
            distance: 0.3,
          ),
          Location(
            id: 'location-2',
            name: 'Ray Club - Norte',
            address: 'Av. Norte, 456',
            latitude: 40.7150,
            longitude: -74.0080,
            phoneNumber: '(11) 5678-1234',
            email: 'norte@rayclub.com',
            openingHours: '06:00 - 22:00',
            amenities: ['Parking', 'Pool'],
            distance: 1.2,
          ),
        ];
        
        // First load all locations
        viewModel.updateState(viewModel.state.copyWith(locations: locations));
        
        // Act
        viewModel.filterLocationsByAmenity('Pool');
        
        // Assert
        expect(viewModel.state.filteredLocations.length, 1);
        expect(viewModel.state.filteredLocations[0].id, 'location-2');
        expect(viewModel.state.selectedAmenityFilter, 'Pool');
      });
      
      // test('clears filter when null is passed', () async {
        // Arrange
        final locations = [
          Location(
            id: 'location-1',
            name: 'Ray Club - Centro',
            address: 'Rua Central, 123',
            latitude: 40.7130,
            longitude: -74.0062,
            phoneNumber: '(11) 1234-5678',
            email: 'centro@rayclub.com',
            openingHours: '06:00 - 22:00',
            amenities: ['Parking', 'Showers', 'Lockers'],
            distance: 0.3,
          ),
          Location(
            id: 'location-2',
            name: 'Ray Club - Norte',
            address: 'Av. Norte, 456',
            latitude: 40.7150,
            longitude: -74.0080,
            phoneNumber: '(11) 5678-1234',
            email: 'norte@rayclub.com',
            openingHours: '06:00 - 22:00',
            amenities: ['Parking', 'Pool'],
            distance: 1.2,
          ),
        ];
        
        // First load all locations and set a filter
        viewModel.updateState(viewModel.state.copyWith(
          locations: locations,
          filteredLocations: [locations[1]],
          selectedAmenityFilter: 'Pool',
        ));
        
        // Act
        viewModel.filterLocationsByAmenity(null);
        
        // Assert
        expect(viewModel.state.filteredLocations, isEmpty);
        expect(viewModel.state.selectedAmenityFilter, isNull);
      });
    });
    
    // group('checkInToLocation', () {
      // test('checks in to location successfully', () async {
        // Arrange
        final locationId = 'location-1';
        final userId = 'user-1';
        
        when(() => mockRepository.checkInToLocation(
          locationId: locationId,
          userId: userId,
        )).thenAnswer((_) async => true);
        
        // Act
        final result = await viewModel.checkInToLocation(
          locationId: locationId,
          userId: userId,
        );
        
        // Assert
        expect(result, isTrue);
        expect(viewModel.state.successMessage, contains('Check-in realizado com sucesso'));
        
        verify(() => mockRepository.checkInToLocation(
          locationId: locationId,
          userId: userId,
        )).called(1);
      });
      
      // test('handles error when check-in fails', () async {
        // Arrange
        final locationId = 'location-1';
        final userId = 'user-1';
        
        when(() => mockRepository.checkInToLocation(
          locationId: locationId,
          userId: userId,
        )).thenThrow(Exception('Falha ao realizar check-in'));
        
        // Act & Assert
        expect(() => viewModel.checkInToLocation(
          locationId: locationId,
          userId: userId,
        ), throwsException);
        
        verify(() => mockRepository.checkInToLocation(
          locationId: locationId,
          userId: userId,
        )).called(1);
      });
    });
  });
} 