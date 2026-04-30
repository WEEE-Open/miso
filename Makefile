# variables
-include .env
export

# detection logic
DOCKER_CMD := $(shell command -v podman 2> /dev/null || command -v docker 2> /dev/null)
IS_DEBIAN  := $(shell [ -f /etc/debian_version ] && echo "yes")

# build pathing
# ensure these evaluate to the same string used by your scripts
BUILD_DIR = $(MISO_BUILD_DIR)/$(MISO_DISTRO_NAME)-$(MISO_ARCH)-$(MISO_PART_TABLE)
IMG_PATH  = $(BUILD_DIR).$(MISO_OUTPUT_EXT)

OVMF_PATH ?= /usr/share/OVMF/OVMF_CODE.fd

.PHONY: build build-container build-debian test prune clean cleanall

# THE ONLY BUILD TARGET
build:
	sudo rm -rf $(BUILD_DIR)/chroot
	chmod +x chroot_scripts/*.sh
ifneq ($(DOCKER_CMD),)
	@echo "--- [$(notdir $(DOCKER_CMD))] detected: building via container ---"
	$(MAKE) build-container
else ifeq ($(IS_DEBIAN),yes)
	@echo "--- no container engine: falling back to local debian build ---"
	$(MAKE) build-debian
else
	$(error ERROR: no podman/docker found and not on debian. cannot build.)
endif

# sentinel for host deps
.deps_installed: install_dep.sh
	@echo "--- checking/installing host dependencies ---"
	sudo ./install_dep.sh
	@touch .deps_installed

# collect sources for dependency tracking
MISO_SRCS := miso.sh $(shell find chroot_scripts -type f 2>/dev/null) .env

# actual file target
$(IMG_PATH): .deps_installed $(MISO_SRCS)
	@mkdir -p $(MISO_BUILD_DIR)
	./miso.sh

build-debian: $(IMG_PATH)

build-container:
	@echo "--- clearing chroot ---"
	sudo rm -rf $(MISO_BUILD_DIR)/chroot
	@mkdir -p $(MISO_BUILD_DIR)
	$(DOCKER_CMD) run -it --rm \
		--name miso \
		--hostname $(MISO_HOSTNAME) \
		--privileged \
		--device /dev/kvm:/dev/kvm \
		--device /dev/fuse:/dev/fuse \
		-v ./build:/miso/build:rw,Z \
		-v ./chroot_scripts:/miso/chroot_scripts:ro,Z \
		-e LIBGUESTFS_BACKEND=direct \
		$$($(DOCKER_CMD) build -q .)

test:
	@if [ ! -f $(IMG_PATH) ]; then \
		echo "ERROR: $(IMG_PATH) missing. run 'make build'."; \
		exit 1; \
	fi
	@case "$(MISO_PART_TABLE)" in \
		gpt) ARGS="-drive if=pflash,format=raw,readonly=on,file=$(OVMF_PATH)" ;; \
		*)   ARGS="" ;; \
	esac; \
	case "$(MISO_OUTPUT_EXT)" in \
		iso) DISK="-cdrom $(IMG_PATH)" ;; \
		*)     DISK="-drive file=$(IMG_PATH),format=raw" ;; \
	esac; \
	qemu-system-x86_64 -accel kvm -m 4G $$ARGS $$DISK

prune:
ifneq ($(DOCKER_CMD),)
	@echo "--- pruning $(notdir $(DOCKER_CMD)) images and build cache ---"
	$(DOCKER_CMD) image prune -f
	$(DOCKER_CMD) builder prune -f
	$(DOCKER_CMD) container rm miso
endif

clean:
	@echo "--- removing intermediate build files ---"
	@if [ -d "$(MISO_BUILD_DIR)" ]; then \
		sudo find $(MISO_BUILD_DIR) -mindepth 1 -maxdepth 1 \
			! -name "*.img" ! -name "*.iso" -exec rm -rf {} +; \
	fi
	rm -f .deps_installed

cleanall: prune
	sudo rm -rf $(MISO_BUILD_DIR)
	rm -f .deps_installed
