import argparse
from {{project_name}}.logging import set_verbosity

def main():
    command_choices = ["list", "status"]

    parser = argparse.ArgumentParser(description='Does a thing')
    parser.add_argument("command", choices=command_choices, metavar=f"command", help='{ '+' | '.join(command_choices)+' }')
    parser.add_argument("-f", help="don't ask for confirmation when overwriting or deleting files", action='store_true')

    #group = parser.add_mutually_exclusive_group()
    #group.add_argument("-v","--verbose", help="verbose level, add more v's for more verbosity", action="count", default=0)
    #group.add_argument("-q","--quiet", help="negative verbose level, add more q's for more quietude", action="count", default=0)

    #set_verbosity(args.verbose - args.quiet)

    args = parser.parse_args()
 
    #Read files, setup state, etc
    #....
    #

    try:
        #if args.command == "status":
        #   pass
        #elif args.command == "list":
        #   pass
        print("{{project_name}}, automatically generated cli tool. TODO: implement")
    except KeyboardInterrupt:
        print("\nCaught interrupt signal, exiting")
