#!/usr/bin/env python3

import argparse
import pprint

verbosity=0

def main():
    command_choices = ["test","run"]
    parser = argparse.ArgumentParser(description='Bars a foo')
    parser.add_argument("command", choices=command_choices, metavar=f"command", help='{ '+' | '.join(command_choices)+' }')
    parser.add_argument("-f","--force", help="don't ask for confirmation when overwriting or deleting files", action='store_true')
    #parser.add_argument("-p", help="command line parameters that override configuration.", nargs='+')

    group = parser.add_mutually_exclusive_group()
    group.add_argument("-v","--verbose", help="verbose level, add more v's for more verbosity", action="count", default=0)
    group.add_argument("-q","--quiet", help="negative verbose level, add more q's for more quietude", action="count", default=0)

    
    args = parser.parse_args()

    global verbosity
    verbosity = args.verbose - args.quiet
    try:   
        if args.command == "test":
            print("test?")
        elif args.command =="run":
            print("run!")
    except KeyboardInterrupt:
        print("\nCaught interrupt signal, exiting")


main()
