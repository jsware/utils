#!/usr/bin/env python3
import argparse, logging

# Parse arguments
parser = argparse.ArgumentParser(description="TODO: Rename this template script.")
parser.add_argument("-v", "--verbose",
                    help="increase output verbosity",
                    default=logging.INFO,
                     action="store_const", const=logging.DEBUG)

args = parser.parse_args()

logging.basicConfig(format="%(message)s", level=args.verbose)
log = logging.getLogger(__name__)

# TODO: Replace this with your actual code.
log.info("Info")
log.debug("Verbose")
