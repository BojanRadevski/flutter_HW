package com.example.explorebuddyback;

import com.example.explorebuddyback.model.Location;
import com.example.explorebuddyback.model.enumeration.LocationType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ILocationsRepository extends JpaRepository<Location,Integer> {
    List<Location> findByName(String name);
    List<Location> findLocationsByTypeIsIn(List<LocationType> locationType);
}