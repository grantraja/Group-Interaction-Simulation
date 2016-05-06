

ArrayList<StatusDetail> statusDetails = new ArrayList<StatusDetail>(); // Status details
ArrayList<PersonalityDetail> personalityDetails = new ArrayList<PersonalityDetail>(); // Personality details
ArrayList<InterestsDetails> interestsDetails = new ArrayList<InterestsDetails>(); // Interests details
ArrayList<Individual> individuals = new ArrayList<Individual>(); // Array list of all the people

float nullFloatVal = 1.23456789; // To signify a null value because can't inject null into an object's float variable

void populateDetails() {
  for (int i = 0; i < statusDetailsNames.length; i++) {
    String label = statusDetailsNames[i];
    float weight = statusDetailsValues[i];
    statusDetails.add(new StatusDetail(label, weight));
  }
  for (int i = 0; i < personalityDetailsNames.length; i++) {
    String label = personalityDetailsNames[i];
    float weight = personalityDetailsValues[i];
    float exponentWeight = personalityDetailsExponentialWeight[i];
    personalityDetails.add(new PersonalityDetail(label, weight, exponentWeight));
  }
  for (int i = 0; i < interestsDetailsNames.length; i++) {
    String label = interestsDetailsNames[i];
    float weight = interestsDetailsValues[i];
    interestsDetails.add(new InterestsDetail(label, weight));
  }
}

class StatusDetail { // For status details
  String label;
  float weight;
  StatusDetail (String str, float val) {
    label = str;
    weight = val;
  }
  void printValues() {
    println(label, weight);
  }
}

class PersonalityDetail {
  String label;
  float weight;
  float exponentWeight;
  PersonalityDetail (String str, float val1, float val2) {
    label = str;
    weight = val1;
    exponentWeight = val2;
  }
  void printValues() {
    println(label, weight, exponentWeight);
  }
}

class InterestsDetail {
  String label;
  float weight;
  PersonalityDetail (String str, float val1) {
    label = str;
    weight = val1;
  }
  void printValues() {
    println(label, weight);
  }
}

void populateIndividuals() {
  println("Populating individuals...");
  for (int i = 0; i < pop; i++) { // Only instance of variable: 'pop'
    // println("Creating person", i); // Feedback
    float[] tempStatusTraits = new float[statusDetailsNames.length]; // Empty array
    float[] tempPersonalityTraits = new float[personalityDetailsNames.length]; // Empty array
    boolean[] tempInterests = new boolean[interestsDetailsNames.length]; // Empty array
    for (int j = 0; j < statusDetails.size(); j++) {
      tempStatusTraits[j] = random(0, 100);
    }
    for (int j = 0; j < personalityDetails.size(); j++) {
      tempPersonalityTraits[j] = random(0, 100);
    }
    for (int j = 0; j < interestsDetailsNames.size(); j++) {
      boolean interestSwitch = false; // Default no interest

      // Chance of having interest
      int percentLikely = 30; // Make it lower so people don't all gravitate towards each other

      int randomVar = random(0, 100); // Random value
      if (randomVar < percentLikely) { // If this person does have the interst
        interestSwitch = true; // Do have the interest
      }
      tempInterests[j] = interestSwitch; // Set randomly as true or false
    }
    individuals.add(new Individual(i, tempPersonalityTraits, tempStatusTraits, tempInterests));
    individuals.get(i).printStatusValues();
  }
}

void compareIndividuals() {
  println("Generating unique attraction values...");
  for (int i = 0; i < individuals.size(); i++) {
    Individual currentPerson = individuals.get(i); // Temporary placeholder
    println("Comparing", currentPerson.personId, "to all others");

    // Sum up all personality traits for yourself, factoring in weight of trait
    float selfTotal = 0; // Single number for net attraction
    for (int j = 0; j < currentPerson.personalityTraits.length; j++) { // Cycle through all personality traits
      float total = 0;
      for (int k = 0; k < personalityDetails.size(); k++) { // Find sum of all weights
        total += personalityDetails.get(k).weight;
      }
      float weightOfTrait = personalityDetails.get(j).weight/total; // Weight of individual trait
      selfTotal += currentPerson.personalityTraits[j] * weightOfTrait;
    }
    println("Self Total:", selfTotal);

    // Generate net attraction on a per person basis
    for (int j = 0; j < individuals.size(); j++) {
      if (j != i) { // If not itself
        Individual comparativePerson = individuals.get(j);
        float netAttraction = 0;
        for (int k = 0; k < currentPerson.personalityTraits.length; k++) { // Cycle through all personality traits
          // More attraction if both high
          float currentPersonalityNet = abs(currentPerson.personalityTraits[k] + comparativePerson.personalityTraits[k]);

          // If different, will decrease attraction - only if drastically different
          float difference = abs(currentPerson.personalityTraits[k] - comparativePerson.personalityTraits[k]);
          difference = difference/10.0; // Decrease magnitidue of effect
          currentPersonalityNet += -1 * pow(difference, personalityDetails.get(k).exponentWeight); // Apply exponent modifier and subtract from net attraction

          // Get weight of this personality trait
          float total = 0;
          for (int m = 0; m < personalityDetails.size(); m++) { // Find sum of all weights
            total += personalityDetails.get(m).weight;
          }
          float weightOfTrait = personalityDetails.get(k).weight/total; // Weight of individual trait

          // Sum up all personality traits for yourself, factoring in weight of trait
          netAttraction += (weightOfTrait * currentPersonalityNet);
        }

        for (int k = 0; k < currentPerson.interestsDetails.length; k++) { // Cycle through interests
          boolean interest1 = currentPerson.interestsDetails[k]; // Store own interest
          boolean interest2 = comparativePerson.interestsDetails[k]; // Store other person's interest

          // Get weight of this interest
          float total = 0;
          for (int m = 0; m < interestsDetails.size(); m++) { // Find sum of all weights
            total += interestsDetails.get(m).weight;
          }
          float weightOfTrait = interestsDetails.get(k).weight/total; // Weight of individual trait

          // Only have an effect if they both have the same interest, no detrimental effect if they don't share the interest
          if (interest1 == interest2) { // If both like it
            netAttraction += (weightOfTrait * 50); // Add scaler
          }
        }

        println("Person", currentPerson.personId, "attraction to person", comparativePerson.personId, "is", netAttraction);
        individuals.get(j).updatePersonalityAttraction(netAttraction); // Update individual's object
      } else { // If comparing to itself
        individuals.get(j).updatePersonalityAttraction(nullFloatVal); // Update individual's object
      }
    }
  }
}

class Individual {
  int personId;
  float[] personalityTraits;
  float[] statusTraits;
  float statusAttraction;
  ArrayList<Float> personalityAttraction = new ArrayList<Float>(0); // Personality attraction to each unique individual

  Individual (int id, float[] personalityTraitsInput, float[] statusTraitsInput, boolean[] interestsInput) { // Declare object
    personId = id;
    personalityTraits = personalityTraitsInput;
    statusTraits = statusTraitsInput;
    interests = interestsInput;

    float temp = 0; // Single number for net attraction
    for (int i = 0; i < statusDetails.size(); i++) {
      float total = 0;
      for (int j = 0; j < statusDetails.size(); j++) {
        total += statusDetails.get(j).weight;
      }
      float weightOfTrait = statusDetails.get(i).weight/total;
      temp += statusTraits[i] * weightOfTrait;
    }
    statusAttraction = temp;
    // println(statusAttraction); // Debugging
  }
  void updatePersonalityAttraction(float netAttraction) { // After created all people must update each individual's relationship to all others
    personalityAttraction.add(netAttraction);
  }
  void printStatusValues() {
    println("ID:", personId);
    for (int i = 0; i < statusTraits.length; i++) {
      String label = statusDetails.get(i).label;
      println(label + ": " + statusTraits[i]);
    }
    println(); // Carriage return
  }
}

void generateAttractionValues() {
  populateDetails(); // Populate objects for ease of access
  println("Populated variable details"); // Feedback
  populateIndividuals(); // Create individuals
  println("Populated individuals"); // Feedback
  compareIndividuals(); // Calculate unique attraction values between each person
  println("Generated attraction values between each individual");
}
