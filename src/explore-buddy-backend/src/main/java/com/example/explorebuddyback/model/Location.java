package com.example.explorebuddyback.model;

import com.example.explorebuddyback.model.enumeration.LocationType;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.persistence.*;

@Entity
@NoArgsConstructor
@Table(name = "location")
@Getter
@Setter
public class Location {
    @Id
    @SequenceGenerator(name = "location_sequence_generator", sequenceName = "location_sequence", allocationSize = 1, initialValue = 1)
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "location_sequence_generator")
    private Integer id;
    private String name;
    private Double lon;
    private Double lat;
    private String description;
    @Enumerated
    private LocationType type;
    public Location(String name, Double lon, Double lat, String description, LocationType locationType){
        this.name=name;
        this.lon=lon;
        this.lat=lat;
        this.description=description;
        this.type=locationType;
    }
}