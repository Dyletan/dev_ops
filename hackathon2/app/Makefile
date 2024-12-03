# Define variables
PYTHON=python3
VENV_DIR=.venv
ACTIVATE=. $(VENV_DIR)/bin/activate

# Define targets
install: $(VENV_DIR)/bin/activate

$(VENV_DIR)/bin/activate: requirements.txt
	@if [ ! -d "$(VENV_DIR)" ]; then \
		echo "Virtual environment not found. Creating..."; \
		$(PYTHON) -m venv $(VENV_DIR); \
	fi
	@echo "Installing dependencies..."
	$(ACTIVATE) && pip install -r requirements.txt

run: install
	$(ACTIVATE) && uvicorn main:app --reload

lint:
	flake8 .

drun:
	docker compose up --build

clean:
	rm -rf $(VENV_DIR)
	docker compose down -v
