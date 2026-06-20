import argparse
import json
import sys
from io import StringIO


class InvertedIndex:
    def __init__(self, path=None):
        self.path = path
        self.index = {}

    def build_inverted_index(self):
        documents = load_documents(self.path)

        for doc_id, text in documents.items():
            cleaned = ""

            for ch in text:
                if ch.isalpha() or ch == " ":
                    cleaned += ch.lower()

            words = set(cleaned.split())

            for word in words:
                if word not in self.index:
                    self.index[word] = {doc_id}
                else:
                    self.index[word].add(doc_id)

    def query(self, words):
        result = None

        for word in words:
            docs = self.index.get(word.lower(), set())

            if result is None:
                result = docs
            else:
                result &= docs

        return sorted(result) if result else []

    def dump(self, filepath):
        data = {}

        for word, doc_ids in self.index.items():
            data[word] = list(doc_ids)

        with open(filepath, "w", encoding="utf-8") as file:
            json.dump(data, file)

    @classmethod
    def load(cls, filepath):
        with open(filepath, "r", encoding="utf-8") as file:
            data = json.load(file)

        obj = cls()

        for word, doc_ids in data.items():
            obj.index[word] = set(doc_ids)

        return obj


def load_documents(filepath):
    documents = {}

    with open(filepath, encoding="utf-8") as file:
        for line in file:
            doc_id, text = line.split("\t", 1)
            documents[int(doc_id)] = text

    return documents


def build_inverted_index(documents):
    index = InvertedIndex()

    for doc_id, text in documents.items():
        cleaned = ""

        for ch in text:
            if ch.isalpha() or ch == " ":
                cleaned += ch.lower()

        words = set(cleaned.split())

        for word in words:
            if word not in index.index:
                index.index[word] = {doc_id}
            else:
                index.index[word].add(doc_id)

    return index


def process_build(dataset, output):
    documents = load_documents(dataset)

    index = build_inverted_index(documents)

    index.dump(output)


def process_query(queries, index):
    inverted_index = InvertedIndex.load(index)

    for line in queries:
        words = line.strip().split()

        result = inverted_index.query(words)

        print(",".join(map(str, result)))


def setup_parser():
    parser = argparse.ArgumentParser()

    subparsers = parser.add_subparsers(dest="command")

    build_parser = subparsers.add_parser("build")
    build_parser.add_argument("--dataset", required=True)
    build_parser.add_argument("--output", required=True)

    query_parser = subparsers.add_parser("query")
    query_parser.add_argument(
        "--index",
        default="inverted.index"
    )
    query_parser.add_argument(
        "--query",
        nargs="+"
    )

    return parser


def main():
    parser = setup_parser()

    args = parser.parse_args()

    if args.command == "build":
        process_build(
            dataset=args.dataset,
            output=args.output
        )

    elif args.command == "query":

        if args.query:
            queries = StringIO(" ".join(args.query))
        else:
            queries = sys.stdin

        process_query(
            queries=queries,
            index=args.index
        )


if __name__ == "__main__":
    main()