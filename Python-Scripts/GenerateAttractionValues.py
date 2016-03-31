import random # For generating random values

numberOfPeople = 120 # Total number of people
print "Creating personality traits for %d" % numberOfPeople

# Trait names and weight - all relative to each other, no upper/lower limit
statusDetails = [
    ["energy", 15.0],
    ["hunger", 7.0],
    ["happiness", 10.0]
]

# Structure: [Name, weight for similarities, exponentWeight for difference (basically what will set people off)]
# Example: ["Kindness", 15.0, 2] --> weight of 15 if two people are the same, difference is squared and therefore emphasized more
personalityDetails = [
    ["Kindness", 15.0, 2],
    ["Temper", -4.0, 2], # Negative weight will do opposite
    ["Intelligence", 9.0, 3],
    ["Popularity", 6.0, 2],
    ["PolitcalCorrectness", 8.0, 3],
    ["Charisma", 13.0, 1],
    ["Attractiveness", 10.0, 0]
]

allPeople = [] # Array of all the Person objects

class Person:
    def __init__(self, personalityTraits, statusTraits):
        self.personalityTraits = personalityTraits # Personality traits
        self.statusTraits = statusTraits # Status traits

        statusAttraction = 0
        for j in range(0, len(statusTraits)): # Create a single status attraction value
            total = 0.0
            for k in range(0, len(statusDetails)): # Find weighting for status trait
                total += abs(statusDetails[k][1]) # Use absolute value for weight
            weightOfTrait = statusDetails[j][1]/total # Find weight of status trait

            statusAttraction += (statusTraits[j] * weightOfTrait) # Add to the status attraction value
        # print statusAttraction # Debugging
        self.statusAttraction = statusAttraction

        self.personalityAttraction = [] # Values for each other individual person, start empty

# *************************** Create People ***************************
for i in range(0, numberOfPeople): # Loop through and create all objects
    print "Creating person %s" % i # Feedback
    personalityTraits = [] # Start empty
    statusTraits = [] # Start empty
    for j in range(0, len(personalityDetails)): # Cycle through all personality traits
        personalityTraits.append(random.uniform(0, 100)) # Set random float between 0 and 100

    for j in range(0, len(statusDetails)): # Cycle through and generate all status traits
        statusTraits.append(random.uniform(0, 100)) # Set random float between 0 and 100
        print "%s trait: %s" % (statusDetails[j][0], statusTraits[j]) # Print each status value

    print "" # Print new line
    allPeople.append(Person(personalityTraits, statusTraits))

# *************************** Comparing to Other People ***************************
print "Created all people. Now generating unique attraction values"
# Once all people created, now can cycle through and calculate unique attraction values
for i in range(0, len(allPeople)):
    print "\nComparing person %s to all others" % i
    currentPerson = allPeople[i]

    # Getting personality value for self
    selfTotal = 0
    for j in range(0, len(currentPerson.personalityTraits)): # Cycle through all personality traits
        # Find weight of this personality trait
        total = 0.0
        for j in range(0, len(personalityDetails)): # Find weighting for personality trait
            total += abs(personalityDetails[j][1]) # Use absolute value for weight
        weightOfTrait = personalityDetails[j][1]/total # Find weight of personality trait

        # Sum up all personality traits for yourself, factoring in weight of trait
        selfTotal += currentPerson.personalityTraits[j] * weightOfTrait # Personal total

    # Generating net attraction on a per person basis
    for j in range(0, len(allPeople)): # Cyle through all other people
        if j != i: # If not itself
            netAttraction = 0
            for k in range(0, len(allPeople[j].personalityTraits)): # Cycle through all personality traits
                # Moree attraction if both high
                currentPersonalityNet = abs(currentPerson.personalityTraits[k] + allPeople[j].personalityTraits[k])

                # If different, will decrease attraction - only if drastically different
                difference = abs(currentPerson.personalityTraits[k] - allPeople[j].personalityTraits[k])
                difference = difference/10.0 # Decrease magnitude of effect
                currentPersonalityNet -= difference ** personalityDetails[k][2] # Apply exponent and subract from net

                # Find weight of this personality trait
                total = 0.0
                for k in range(0, len(personalityDetails)): # Find weighting for personality trait
                    total += abs(personalityDetails[k][1]) # Use absolute value for weight
                weightOfTrait = personalityDetails[k][1]/total # Find weight of personality trait

                # Sum up all personality traits for yourself, factoring in weight of trait
                netAttraction += (weightOfTrait * currentPersonalityNet) # Add them all together

            print "Person %s attraction to person %s is %s" % (i, j, netAttraction) # Feedback
            allPeople[i].personalityAttraction.append(netAttraction) # Push to array
        else:
            allPeople[i].personalityAttraction.append("NULL") # Push NULL value for attraction to yourself
