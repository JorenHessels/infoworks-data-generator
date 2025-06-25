class FileParser:
    def __init__(self, filepath):
        self.filepath = filepath
        self.entries = []

    def parse(self):
        with open(self.filepath, 'r', encoding='utf-8') as file:
            for line in file:
                line = line.strip()
                if not line:
                    continue  # Skip empty lines

                try:
                    id_part, full_path = line.split(' - ', 1)
                    path_id = int(id_part.strip())
                    short = full_path.split('~')[-1].strip()

                    path = Path(path_id, full_path, short)
                    self.entries.append(path)
                except ValueError:
                    print(f"Skipping malformed line: {line}")

    def get_entries(self):
        return self.entries


class Path:
    def __init__(self, path_id, full, short):
        self.id = path_id
        self.full = full
        self.short = short

    def __repr__(self):
        return f"Path(id={self.id}, full='{self.full}', short='{self.short}')"
