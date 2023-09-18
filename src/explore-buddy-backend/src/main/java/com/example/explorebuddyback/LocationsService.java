package com.example.explorebuddyback;

import com.example.explorebuddyback.helpers.CSVHelper;
import com.example.explorebuddyback.model.Location;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@Service
public class LocationsService {

    private final ILocationsRepository locationsRepository;

    public LocationsService(ILocationsRepository locationsRepository) {
        this.locationsRepository = locationsRepository;
    }

    public List<Location> getAll() {
        return locationsRepository.findAll();
    }

    public List<Location> importFromCsv(MultipartFile file) {
        try {
            String name = file.getOriginalFilename().substring(0, file.getOriginalFilename().length() - 4);
            List<Location> locations = CSVHelper.csvToLocations(file.getInputStream(), name);
            locationsRepository.saveAll(locations);
            return locations;
        } catch (IOException e) {
            throw new RuntimeException("fail to store csv data: " + e.getMessage());
        }
    }
}
