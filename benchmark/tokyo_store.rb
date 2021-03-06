#
# Tokyo Store
#
# Benchmark vs MemCacheStore on memcached and tyrant
#
require 'rubygems'
require 'active_support'
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'tokyo_store'
#include TokyoCabinet

P = "x" * 100
M = P * 10
G = M * 10
OBJ = { :small => P, :medium => M, :big => G}

@tokyo = ActiveSupport::Cache.lookup_store :tokyo_store, "localhost:45001"
@memca = ActiveSupport::Cache.lookup_store :mem_cache_store, "localhost:11211"
@memto = ActiveSupport::Cache.lookup_store :mem_cache_store, "localhost:45001"

# # # Read & Write
 Benchmark.bmbm do |b|
  b.report("TokyoStore# P") { 10_000.times { |i| @tokyo.write i.to_s, P }}
  b.report("MemCacheD # P") { 10_000.times { |i| @memca.write i.to_s, P }}
  b.report("MemCacheT # P") { 10_000.times { |i| @memto.write i.to_s, P }}
  b.report("TokyoStore# M") { 10_000.times { |i| @tokyo.write i.to_s, M }}
  b.report("MemCacheD # M") { 10_000.times { |i| @memca.write i.to_s, M }}
  b.report("MemCacheT # M") { 10_000.times { |i| @memto.write i.to_s, M }}
  b.report("TokyoStore# G") { 10_000.times { |i| @tokyo.write i.to_s, G }}
  b.report("MemCacheD # G") { 10_000.times { |i| @memca.write i.to_s, G }}
  b.report("MemCacheT # G") { 10_000.times { |i| @memto.write i.to_s, G }}
  b.report("TokyoStore# OB") { 10_000.times { |i| @tokyo.write i.to_s, OBJ }}
  b.report("MemCacheD # OB") { 10_000.times { |i| @memca.write i.to_s, OBJ }}
  b.report("MemCacheT # OB") { 10_000.times { |i| @memto.write i.to_s, OBJ }}
  b.report("TokyoStore# R") { 10_000.times { |i| @tokyo.read i.to_s }}
  b.report("MemCacheD # R") { 10_000.times { |i| @memca.read i.to_s }}
  b.report("MemCacheT # R") { 10_000.times { |i| @memto.read i.to_s }}
 end

puts
thr = []
# # Read & Write
Benchmark.bmbm do |b|
  b.report("Tokyo # W") {  100.times { |j| thr << Thread.new { 100.times { |i| @tokyo.write "#{j}-#{i}", OBJ }}};  thr.each { |t| t.join }; thr = [] }
  b.report("MemCa # W") {  100.times { |j| thr << Thread.new { 100.times { |i| @memca.write "#{j}-#{i}", OBJ}}};  thr.each { |t| t.join }; thr = [] }
  b.report("MemTo # W") {  100.times { |j| thr << Thread.new { 100.times { |i| @memto.write "#{j}-#{i}", OBJ}}};  thr.each { |t| t.join }; thr = [] }
  b.report("Tokyo # R") {  100.times { |j| thr << Thread.new { 100.times { |i| @tokyo.read "#{j}-#{i}" }}};  thr.each { |t| t.join }; thr = [] }
  b.report("MemCa # R") {  100.times { |j| thr << Thread.new { 100.times { |i| @memca.read "#{j}-#{i}"}}};  thr.each { |t| t.join }; thr = [] }
  b.report("MemTo # R") {  100.times { |j| thr << Thread.new { 100.times { |i| @memto.read "#{j}-#{i}"}}};  thr.each { |t| t.join }; thr = [] }
end


__END__



Core 2 Duo 8500 - 3.16Ghz
------------------------------------------------------------
TokyoStore# P    0.140000   0.090000   0.230000 (  0.367587)
MemCacheD # P    0.570000   0.160000   0.730000 (  0.829167)
MemCacheT # P    0.560000   0.170000   0.730000 (  0.897084)
TokyoStore# M    0.170000   0.100000   0.270000 (  0.448071)
MemCacheD # M    0.610000   0.140000   0.750000 (  0.878559)
MemCacheT # M    0.630000   0.140000   0.770000 (  0.951748)
TokyoStore# G    0.410000   0.090000   0.500000 (  0.976746)
MemCacheD # G    1.000000   0.200000   1.200000 (  1.429635)
MemCacheT # G    1.060000   0.170000   1.230000 (  1.558731)
TokyoStore# OB   0.480000   0.130000   0.610000 (  1.299556)
MemCacheD # OB   1.460000   0.280000   1.740000 (  1.980678)
MemCacheT # OB   1.230000   0.230000   1.460000 (  1.856561)
TokyoStore# R    0.620000   0.230000   0.850000 (  1.204192)
MemCacheD # R    0.550000   0.110000   0.660000 (  0.748446)
MemCacheT # R    1.490000   0.260000   1.750000 (  2.142504)

Tokyo # W   0.500000   0.100000   0.600000 (  1.189529)
MemCa # W   2.390000   0.250000   2.640000 (  2.942472)
MemTo # W   2.550000   0.260000   2.810000 (  3.121612)
Tokyo # R   0.660000   0.230000   0.890000 (  1.266911)
MemCa # R   1.550000   0.190000   1.740000 (  1.824773)
MemTo # R   3.170000   0.280000   3.450000 (  3.908895)
