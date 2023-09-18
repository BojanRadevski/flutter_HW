package com.example.explorebuddyback;

import com.example.explorebuddyback.helpers.CSVHelper;
import com.example.explorebuddyback.model.Location;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;

@RestController
@CrossOrigin
@RequestMapping("/home")
public class LocationController {

    private final LocationsService locationsService;

    public LocationController(LocationsService locationsService) {
        this.locationsService = locationsService;
    }

    @GetMapping
    public List<Location> getLocations(){
        return locationsService.getAll();
    }

    @PostMapping("/importCsv")
    public ResponseEntity<List<Location>> postLocations(@RequestParam("file") MultipartFile file){
        List<Location> locations=new ArrayList<>();
        if (CSVHelper.hasCSVFormat(file)) {
            locations=locationsService.importFromCsv(file);
        }
        return ResponseEntity.status(HttpStatus.OK).body(locations);
    }
}
