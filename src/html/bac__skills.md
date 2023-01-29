
<!-- .margin.compass -->
* _Character Creation_
* Summary
* Backgrounds
* **Skills**
* Traits
* Equipment


<!-- <div.two-columns> -->
<!-- <div.left-column> -->

# Skills

More like skill domains, some of those domains overlap.

When a character acquires a skill, they start at +0. If a character has not been exposed to the skills, they have a default -2.

A character may have at most a `level + 1` skill score.


## ~~F~~ Fighter Skills

Bows / Crossbows / Slings / Javelins / Throw
: Shoot with a given type of ranged weapon (or throw a rock).

Axes / Maces / Staves / Spears / Swords / Knives
: Fight with a given type of melee weapon.

Punch / Grapple
: Fight unarmed. Punching and grappling are separate.

Shields
: To use a shield, defensively and offensively.

Dodge
: To avoid hits and projectiles.


## ~~M~~ Magic Skills

Throw
: To weave to project.

Wrap
: To weave to surround.

Bind
: To weave to connect.

Feel
: To weave to perceive.

Soak
: To weave to absorb.

Radiate
: To weave to emit.


<!-- </div.left-column> -->
<!-- <div.right-column> -->


## ~~G~~ General Skills

Administer
: To manage land and laborers, or a workshop, its journeyfolk and apprentices.

Build
: To build structures, to appraise such structures (traps and anomalies?).

Cook
: To prepare meals

Exert
: To climb, run, lift, throw. Athletic training.

Fish
: To catch fish and other aquatic creatures.

Gather
: To gather herbs, mushrooms, to identify plants.

Grow
: To cultivate crops and the like.

Heal
: To mend wounds, combat diseases, neutralize poisons, and stabilise _Wounded_ characters.

Herd
: To herd cattle, to take care of the animals.

Hunt
: To take game with snare, arrow or spear, more widely gamekeeping.

Lead
: To conduct and inspire people.

Log
: Felling and logging trees, more widely, sylviculture.

Negotiate
: To talk, to convince.

Perform
: To sing, dance, or play an instrument. To know songs and stories.

Pray
: To know how to perform the religious rites, to know the religious history.

Read
: At +0, read. From +1 on, read and write.

Ride
: To ride an animal, to drive a cart or carriage. To take care of the animal.

Sail
: To sail and navigate a ship, to build a craft. To read sea weather, to manage sailors.

Scout
: To gather information, unnoticed.

Spy
: To observe, to notice. To gather information.

Steal
: To lay one's hands on something.

Swim
: To swim, to be at ease in the water.

Trade
: To buy and sell advantageously, to value goods correctly, to deal with traders.

Travel
: To be used to travel.

Craft
: One of the many crafts of the era.

Know
: Grammar, logic, rhetoric, then arithmetic, geometry, music, astronomy.
: Or something else.

<!--
  craftsmen:

  * ale maker
  * weaponsmith
  * blacksmith
  * carpenter
  * lumberjack
  * charcoal maker
  * miller
  * butcher
  * baker
  * wheelwright
  * coppersmith
  * shoemaker
  * mason
  * joiner
  * miner
  * potter
  * sadler
  * stonecutter
  * tanner
  * cooper
  * shipwright
  * cabinet maker
  * rope maker
-->

<!-- </div.right-column> -->
<!-- </div.two-columns> -->

<script>

onDocumentReady(function() {
  elts('section[data-aa-title="skills"] dt')
    .forEach(function(e) {
      if ( ! (e.textContent === 'Craft' || e.textContent === 'Know')) return;
      e.classList.add('generic');
    });
});

</script>
