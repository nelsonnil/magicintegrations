# MagicIntregations

In this package you will find the functions necessary to retrieve data from the following magic games:

## Inject

Observed object to retrieve Inject game data.

## Usage

1. Instance object in your view as an @StateObject or @ObservedObject.

2. Call load() function to get JSON data from the game URL.

3. inject.count is persisted as UserDefaults. A change in this parameter will trigger a change in the Published variable of the Observed Object.

## WikiTest

Observed object to retrieve WikiTest game data.

## Usage

1. Instance object in your view as an @StateObject or @ObservedObject.

2. Call load() function to get JSON data from the URL.

3. wikitest.modified is persisted as UserDefaults. A change in this parameter will trigger a change in the Published variable of the Observed Object.

## Elips

Observed object to retrieve Elips game data.

## Usage

1. Instance object in your view as an @StateObject or @ObservedObject

2. Call load() function to get JSON data from the URL

3. elips.count is persisted as UserDefaults. A change in this parameter will trigger a change in the Published variable of the Observed Object.

## Mental Dice

Observed object to connect a get Dice values.

### Usage

1. Instance object in your view as an @StateObject or @ObservedObject

2. Call connect() function to perform Bluetooth bonding to Mental Dice.

3. After the app is properly connected you can access an array of **Die** with **value** and **color** in it.


To configure the URL to access every game you can use the:

## Custom Api

Observed object to get json data, and the value of a field.

### Usase

1. Instance object in your view as an @StorageObject or @ObservedObject

2. Call load() function to get JSON data from the URL

3. The value of the field is persisted in UseDefaults. A change in the value of this field will trigger a chang in the Published variable of the Observed Object.
