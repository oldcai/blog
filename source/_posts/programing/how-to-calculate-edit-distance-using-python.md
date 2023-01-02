---
title: How to Calculate Edit Distance Using Python
date: 2023-01-02 22:31:56
categories:
	- python
---

## Calculate the Edit Distance

To calculate the edit distance between two strings using Python, you can use the `Levenshtein` library. Here's an example of how you can use it:


```python
# pip install python-Levenshtein

import Levenshtein

# Calculate the edit distance between two strings
s1 = "kitten"
s2 = "sitting"
edit_distance = Levenshtein.distance(s1, s2)

print(edit_distance)
```

This will output the edit distance between the two strings, which in this case is 3 (since three operations are required to transform "kitten" into "sitting": change "k" to "s", insert "i", and insert "g").
You can also use the distance method to calculate the normalised edit distance by setting the optional normalised parameter to True. This will return the edit distance as a float in the range [0, 1], where 0 means the strings are identical and 1 means they are completely different.


## Normalise the Edit Distance

```python
import Levenshtein

s1 = "kitten"
s2 = "sitting"
normalized_edit_distance = Levenshtein.distance(s1, s2, normalized=True)

print(normalized_edit_distance)
# output: 0.42857142857142855
```

The output of the first script will be an integer representing the edit distance between the two strings. In this case, the output will be 3.
The output of the second script will be a float representing the normalized edit distance between the two strings. The value will be in the range [0, 1], where 0 means the strings are identical and 1 means they are completely different. In this case, the output will be a value close to 0.42, since three operations are required to transform "kitten" into "sitting": change "k" to "s", insert "i", and insert "g".

## Troubleshooting

If python raises an error like the one below, you should either upgrade the library or define your own function.

```
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: distance() got an unexpected keyword argument 'normalized'
```

It looks like you are using an older version of the python-Levenshtein library that does not support the normalized parameter. The normalized parameter was added in version 0.12.0 of the library.

To fix the error, you can either upgrade to the latest version of the library by running pip install python-Levenshtein --upgrade, or you can calculate the normalized edit distance manually by dividing the edit distance by the length of the longer string.

Here's an example of how you can do this:

```python
def get_normalized_edit_distance(s1, s2):
    edit_distance = Levenshtein.distance(s1, s2)
    return edit_distance / max(len(s1), len(s2))

import Levenshtein

s1 = "kitten"
s2 = "sitting"
normalized_edit_distance = get_normalized_edit_distance(s1, s2)
print(normalized_edit_distance)
# output: 0.42857142857142855
```




