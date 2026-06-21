import argparse
import json
import sys
import re
from io import StringIO


class InvertedIndex:
    def __init__(self, path=None):
        self.path = path
        self.index = {}

    def query(self, words):
        result = None
        print("INDEX KEYS SAMPLE:", list(self.index.keys())[:10])
        print("QUERY WORDS:", words)

        for word in words:
            word = word.lower()
            docs = self.index.get(word, set())

            if result is None:
                result = docs
            else:
                result &= docs

        return sorted(result) if result else []

    def dump(self, filepath):
        data = {
            word: list(doc_ids)
            for word, doc_ids in self.index.items()
        }

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
        for i, line in enumerate(file):
            line = line.strip()

            if line:  # skip empty lines
                documents[i] = line

    return documents


def build_inverted_index(documents):
    index = InvertedIndex()

    for doc_id, text in documents.items():
        words = set(re.findall(r"[a-zA-Z]+", text.lower()))

        for word in words:
            if word not in index.index:
                index.index[word] = {doc_id}
            else:
                index.index[word].add(doc_id)

    return index


def process_build(dataset, output):
    documents = load_documents(dataset)
    index = build_inverted_index(documents)

    print("FINAL DOC COUNT:", len(documents))
    print("FINAL INDEX SIZE:", len(index.index))

    index.dump(output)


def process_query(queries, index_path):
    inverted_index = InvertedIndex.load(index_path)

    for line in queries:
        line = line.strip()
        if not line:
            continue

        words = re.findall(r"[a-zA-Z]+", line.lower())

        result = inverted_index.query(words)

        print(",".join(map(str, result)))


def setup_parser():
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)

    build_parser = subparsers.add_parser("build")
    build_parser.add_argument("--dataset", required=True)
    build_parser.add_argument("--output", required=True)

    query_parser = subparsers.add_parser("query")
    query_parser.add_argument("--index", default="inverted.index")
    query_parser.add_argument("--query", nargs="+")
    query_parser.add_argument("--from_file")

    return parser


def main():
    parser = setup_parser()
    args = parser.parse_args()

    print("COMMAND:", args.command)

    if args.command == "build":
        process_build(args.dataset, args.output)

    elif args.command == "query":

        if args.from_file:
            with open(args.from_file, encoding="utf-8") as f:
                process_query(f, args.index)

        elif args.query:
            queries = StringIO(" ".join(args.query))
            process_query(queries, args.index)

        else:
            process_query(sys.stdin, args.index)


if __name__ == "__main__":
    main()