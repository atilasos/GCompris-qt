/* GCompris - Data.qml
 *
 * SPDX-FileCopyrightText: 2024 Johnny Jazeix <jazeix@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import core 1.0

// Offline questions; teachers can also supply their own datasets.
Data {
    objective: qsTr("Find the correct answers.")
    difficulty: 1
    data: [
        {
            "shuffle": true,
            "subLevels": [
            {
                "shuffleAnswers": true,
                "question": qsTr("Which number comes immediately after 2?"),
                "answers": ["1", "2", "3"],
                "correctAnswers": ["3"],
                "correctAnswerText": qsTr("3 comes immediately after 2."),
                "wrongAnswerText": qsTr("Count: 1, 2, 3."),
                "mode": "oneAnswer"
            },
            {
                "shuffleAnswers": false,
                "question": qsTr("Which answer is a color?"),
                "answers": [qsTr("yellow"), "12", qsTr("cat")],
                "correctAnswers": [qsTr("yellow")],
                "correctAnswerText": qsTr("Yellow is a color."),
                "wrongAnswerText": qsTr("Choose the color, not the animal or the number."),
                "mode": "oneAnswer"
            }
            ]
        },
        {
            "shuffle": false,
            "subLevels": [
            {
                "shuffleAnswers": true,
                "question": qsTr("Which numbers are smaller than 3?"),
                "answers": ["1", "2", "3"],
                "correctAnswers": ["1", "2"],
                "correctAnswerText": qsTr("1 and 2 are smaller than 3."),
                "wrongAnswerText": qsTr("Select both 1 and 2, without selecting 3."),
                "mode": "multipleAnswers"
            },
            {
                "shuffleAnswers": true,
                "question": qsTr("Which answers are animals?"),
                "answers": [qsTr("cat"), qsTr("dog"), "3"],
                "correctAnswers": [qsTr("cat"), qsTr("dog")],
                "correctAnswerText": qsTr("Cats and dogs are animals."),
                "wrongAnswerText": qsTr("Select the cat and the dog, not the number."),
                "mode": "multipleAnswers"
            }
            ]
        },
        {
            "shuffle": false,
            "subLevels": [
            {
                "shuffleAnswers": false,
                "question": qsTr("How many sides does a triangle have?"),
                "answers": ["1", "2", "3"],
                "correctAnswers": ["3"],
                "mode": "oneAnswer"
            }
            ]
        }
    ]
}
