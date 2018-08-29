#! /usr/bin/env python3

import sys

hex = sys.argv[1]
# h = input('Enter hex: ').lstrip('#')
# print('RGB =', tuple(int(h[i:i+2], 16) for i in (0, 2 ,4)))
# print(tuple(int(hex[i:i+2], 16) for i in (0, 2, 4)))
print(int(hex[0:2], 16), int(hex[2:4], 16), int(hex[4:6], 16), sep=',')
# print('' + int(hex[i:i+2], 16) + ',' for i in (0, 2, 4))
