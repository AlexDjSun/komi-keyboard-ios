import argparse
import json
import os
import tempfile


def load_json(path):
    with open(path, "r", encoding="utf-8") as file:
        return json.load(file)


def validate_field(value):
    if "\t" in value or "\n" in value or "\r" in value:
        raise ValueError(f"Model field contains an unsupported control character: {value!r}")
    return value


def write_ranked_section(output, name, values, suggestion_limit=3):
    output.write(f"[{name}]\n")
    for context in sorted(values):
        suggestions = sorted(
            values[context].items(),
            key=lambda item: item[1],
            reverse=True,
        )[:suggestion_limit]
        if not suggestions:
            continue
        fields = [validate_field(context)]
        fields.extend(validate_field(word) for word, _ in suggestions)
        output.write("\t".join(fields) + "\n")


def compile_model(input_dir, output_file):
    unigrams = load_json(os.path.join(input_dir, "unigram_probs.json"))
    completions = load_json(os.path.join(input_dir, "completion_probs.json"))
    bigrams = load_json(os.path.join(input_dir, "bigram_probs.json"))
    trigrams = load_json(os.path.join(input_dir, "trigram_probs.json"))
    capitalization = load_json(
        os.path.join(input_dir, "cap_patterns_probs.json")
    )

    output_dir = os.path.dirname(os.path.abspath(output_file))
    os.makedirs(output_dir, exist_ok=True)
    descriptor, temporary_path = tempfile.mkstemp(
        prefix="prediction_model_",
        suffix=".txt",
        dir=output_dir,
    )

    try:
        with os.fdopen(descriptor, "w", encoding="utf-8", newline="\n") as output:
            output.write("[unigram]\n")
            for word in sorted(unigrams):
                output.write(
                    f"{validate_field(word)}\t{unigrams[word]:.9g}\n"
                )

            write_ranked_section(output, "completion", completions)
            write_ranked_section(output, "bigram", bigrams)
            write_ranked_section(output, "trigram", trigrams)

            output.write("[capitalization]\n")
            for word in sorted(capitalization):
                patterns = capitalization[word]
                if not patterns:
                    continue
                best_pattern = max(patterns.items(), key=lambda item: item[1])[0]
                output.write(
                    f"{validate_field(word)}\t{validate_field(best_pattern)}\n"
                )

        os.replace(temporary_path, output_file)
    except BaseException:
        if os.path.exists(temporary_path):
            os.unlink(temporary_path)
        raise


def main():
    parser = argparse.ArgumentParser(
        description="Compile prediction JSON files into the compact runtime model."
    )
    parser.add_argument("input_dir")
    parser.add_argument("output_file")
    arguments = parser.parse_args()
    compile_model(arguments.input_dir, arguments.output_file)


if __name__ == "__main__":
    main()
