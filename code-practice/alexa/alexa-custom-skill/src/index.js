/**
    Copyright 2014-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.

    Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at

        http://aws.amazon.com/apache2.0/

    or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/


'use strict';

var AlexaSkill = require('./AlexaSkill'),
    meds = require('./side_effects'),
    contacts = require('./contacts');

var APP_ID = undefined; //replace with 'amzn1.echo-sdk-ams.app.[your-unique-value-here]';

var ONE_LINERS = [
    "What does a nosey pepper do? Get halapen yo business...",
    "How does nasa organize their company parties? They plan it...",
    "Why can't you hear a pterodactyl go to the bathroom? Because the P is silent...",
    "What kind of shoes do ninjas wear? Sneakers...",
    "Did you hear about the new corduroy pillows? They're making headlines everywhere...",
    "Why was six afraid of seven? Because seven was a well known six offender...",
    "My friend recently got crushed by a pile of books, but he's only got his shelf to blame...",
    "Why can't a bike stand on its own? It's two tired...",
    "I wondered why the baseball was getting bigger. ,,Then it hit me...",
    "I Just went to an emotional wedding. Even the cake was in tiers...",
    "When you get a bladder infection. urine trouble...",
    "I wrote a song about a tortilla. Well actually, it's more of a wrap...",
    "Learn sign language, it's very handy...",
    "I started a band called 999 Megabytes. we haven't gotten a gig yet...",
    "You want to hear a pizza joke? Never mind, it's pretty cheesy....",
    "What do you get if you cross a duck with fireworks? A fire quacker...",
    "What do you call it when it rains chickens and ducks? Foul weather...",
    "A duck walks into a pharmacy and says, Do you have any chapstick? When the pharmacist hands it to him, the duck replies, Thanks, just put it on my bill...",
    "I went to a record store, they said they specialized in hard-to-find records. nothing was alphabetized.",
    "What do you call a dog with a surround system?  A sub-woofer...",
    "Why did the dog cross the road? To get to the barking lot!...",
    "What happened when the dog went to the flea circus?   He stole the show!...",
    "What does my dog and my phone have in common?   They both have collar ID...",
    "What did one ocean say to the other ocean?  Nothing, they just waved...",
    "What is faster Hot or cold? Hot, because you can catch a cold...",
    "A man walks into a zoo. The only animal in the entire zoo is a dog.  It's a shit zoo",
    "Bill gates farted in the Apple store and stunk up the entire place.  But it was their fault for not having windows.",
    "Did you hear about the two antennas who got married? It was a nice ceremony, but the reception was amazing",
    "What kind of bagel can fly?  A plain bagel",
    "What do you call a bear with no teeth?  A gummy bear",
    "Why didn't the skeleton cross the road?  Because he had no guts",
    "Where does a polar bear hide his money?  A snow bank"
]

var REACTIONS = [
    "Many say that joke hurts",
    "Many cry themselves to sleep at night",
    "Many say the pain is unbearable",
    "Many say the pain is excruciating",
    "Many lock themselves in the bathroom after hearing that joke",
    "Many say they wish they can unhear that joke",
    "Many say they wish they have the last 10 seconds of their life back",
    "Many have already notified HR of the pain from that joke",
    "The ear plugs are in the medical kit in the kitchen",
    "Many are often speechless from that joke",
    "I'm sorry I had to repeat that joke",
    "Many usually walk away when the joke is told",
    "Many usually run away when that joke is told",
    "Many usually cover their ears when the joke starts",
    "You'll find the anti-nausea pills in the kitchen"
    ]

/**
 * SideEffectsHelper is a child of AlexaSkill.
 * To read more about inheritance in JavaScript, see the link below.
 *
 * @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Introduction_to_Object-Oriented_JavaScript#Inheritance
 */
var SideEffectsHelper = function () {
    AlexaSkill.call(this, APP_ID);
};

// Extend AlexaSkill
SideEffectsHelper.prototype = Object.create(AlexaSkill.prototype);
SideEffectsHelper.prototype.constructor = SideEffectsHelper;

SideEffectsHelper.prototype.eventHandlers.onLaunch = function (launchRequest, session, response) {
    var speechText = "Welcome to Reactive.  You can ask a question like, what are the side effects for Advil. or where does Bryan Praditkul sit. or tell me about Kaden ... Now, what can I help you with.";
    // If the user either does not reply to the welcome message or says something that is not
    // understood, they will be prompted again with this text.
    var repromptText = "For instructions on what you can say, please say help me.";
    response.ask(speechText, repromptText);
};

SideEffectsHelper.prototype.intentHandlers = {
    "GetContactInfoIntent": function (intent, session, response) {
        var contactSlot = intent.slots.Contact,
            contactName;
        if (contactSlot && contactSlot.value){
            contactName = contactSlot.value.toLowerCase();
        }

        var cardTitle = "Info for " + contactName,
            contact = contacts[contactName],
            speechOutput,
            repromptOutput;
        if (contact) {
            var jokeIndex = Math.floor(Math.random() * ONE_LINERS.length);
            var joke = ONE_LINERS[jokeIndex];

            var reactionIndex = Math.floor(Math.random() * REACTIONS.length);
            var reaction = REACTIONS[reactionIndex];

            if (contactName == "foo" || contactName == "my family" || contactName == "my family values") {
                speechOutput = {
                    speech: contact,
                    type: AlexaSkill.speechOutputType.PLAIN_TEXT
                };
                response.tellWithCard(speechOutput, cardTitle, contact);
            }
            else {
                speechOutput = {
                    speech: "<speak><p>" + contact + ' The joke ' + contactName + ' repeatedly tells around the office is: ' + joke + '</p><break time="1s"/><p>' + reaction + "</p></speak>",
                    //type: AlexaSkill.speechOutputType.PLAIN_TEXT
                    type: AlexaSkill.speechOutputType.SSML
                };
                response.tellWithCard(speechOutput, cardTitle, contact);
            }
        } else {
            var speech;
            if (contactName) {
                speech = "I'm sorry, I can't find information for " + contactName + ". Who else can I help with?";
            } else {
                speech = "I'm sorry, I currently do not know anyone by that name. Who else can I help with?";
            }
            speechOutput = {
                speech: speech,
                type: AlexaSkill.speechOutputType.PLAIN_TEXT
            };
            repromptOutput = {
                speech: "Who else can I help with?",
                type: AlexaSkill.speechOutputType.PLAIN_TEXT
            };
            response.ask(speechOutput, repromptOutput);
        }
    },


    "GetSideEffectsIntent": function (intent, session, response) {
        var medSlot = intent.slots.Med,
            medName;
        if (medSlot && medSlot.value){
            medName = medSlot.value.toLowerCase();
        }

        var cardTitle = "Side effects for " + medName,
            med = meds[medName],
            speechOutput,
            repromptOutput;
        if (med) {
            speechOutput = {
                speech: med,
                type: AlexaSkill.speechOutputType.PLAIN_TEXT
            };
            response.tellWithCard(speechOutput, cardTitle, med);
        } else {
            var speech;
            if (medName) {
                speech = "I'm sorry, I currently do not know the side effects for " + medName + ". What else can I help with?";
            } else {
                speech = "I'm sorry, I currently do not know those side effects. What else can I help with?";
            }
            speechOutput = {
                speech: speech,
                type: AlexaSkill.speechOutputType.PLAIN_TEXT
            };
            repromptOutput = {
                speech: "What else can I help with?",
                type: AlexaSkill.speechOutputType.PLAIN_TEXT
            };
            response.ask(speechOutput, repromptOutput);
        }
    },

    "AMAZON.StopIntent": function (intent, session, response) {
        var speechOutput = "Thanks for trying Collective Health Reactive";
        response.tell(speechOutput);
    },

    "AMAZON.CancelIntent": function (intent, session, response) {
        var speechOutput = "Thanks for trying Collective Health Reactive";
        response.tell(speechOutput);
    },

    "AMAZON.HelpIntent": function (intent, session, response) {
        var speechText = "You can ask a question like, what are the side effects for Advil? Or where does Christian Nuss sit? Or tell me about Collective Health values Now, what can I help you with?";
        var repromptText = "You can ask a question like, what are the side effects for Tylenol? Or where does Maddy Wilson sit? Or tell me about Collective Health values or you can say exit... Now, what can I help you with?";
        var speechOutput = {
            speech: speechText,
            type: AlexaSkill.speechOutputType.PLAIN_TEXT
        };
        var repromptOutput = {
            speech: repromptText,
            type: AlexaSkill.speechOutputType.PLAIN_TEXT
        };
        response.ask(speechOutput, repromptOutput);
    }
};

exports.handler = function (event, context) {
    var sideEffectsHelper = new SideEffectsHelper();
    sideEffectsHelper.execute(event, context);
};

