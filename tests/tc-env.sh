#!/usr/bin/env bash
# powerpc-toolchain-env.sh
# Usage: source this to activate your PowerPC cross-toolchain with proper specs patch

# --- Configuration ---
export TARGET=powerpc-linux-gnu
export TOOLCHAIN_ROOT="$(realpath "../toolchain")"
export SYSROOT_PREFIX="$PREFIX/$TARGET/sysroot"
export SYSROOT="$TOOLCHAIN_ROOT$SYSROOT_PREFIX"
export BIN="$TOOLCHAIN_ROOT/bin"

# --- Export environment ---
export PATH="$BIN:$PATH"
export CC="$TARGET-gcc"
export CXX="$TARGET-g++"
export AR="$TARGET-ar"
export AS="$TARGET-as"
export LD="$TARGET-ld"
export RANLIB="$TARGET-ranlib"
export STRIP="$TARGET-strip"
export OBJCOPY="$TARGET-objcopy"
export OBJDUMP="$TARGET-objdump"

# --- Confirm ---
echo "[✓] PowerPC toolchain environment loaded"
echo "[✓] Using: $CC --sysroot=$SYSROOT"
$CC --sysroot="$SYSROOT" -v -E - < /dev/null | grep "/usr/include" || true
